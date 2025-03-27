package main

import (
	"context"
	"fmt"
	"log/slog"
	"math/big"
	"os/signal"
	"syscall"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ilyakaznacheev/cleanenv"
)

type Config struct {
	RPC        string        `yaml:"rpc" env:"RPC" env-required:"true"`
	PrivateKey string        `yaml:"private_key" env:"PRIVATE_KEY" env-required:"true"`
	Interval   time.Duration `yaml:"interval" env:"INTERVAL" env-default:"10s"`
	GasLimit   uint64        `yaml:"gas_limit" env:"GAS_LIMIT" env-default:"200000"`
}

func main() {
	ctx, cancel := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM,
	)

	defer cancel()

	slog.Info("Start tx-generator")
	if err := run(ctx); err != nil {
		slog.Error("failed to run", "error", err.Error())
	}

	slog.Info("Stop tx-generator")
}

func run(ctx context.Context) error {
	cfg, err := loadConfig()
	if err != nil {
		return fmt.Errorf("load config: %w", err)
	}

	ticker := time.NewTicker(cfg.Interval)
	defer ticker.Stop()

	client, err := ethclient.DialContext(ctx, cfg.RPC)
	if err != nil {
		return fmt.Errorf("dial rpc: %w", err)
	}

	defer client.Close()

	priv, err := crypto.HexToECDSA(cfg.PrivateKey)
	if err != nil {
		return fmt.Errorf("hex to ecdsa: %w", err)
	}

	addr := crypto.PubkeyToAddress(priv.PublicKey)

	nonce, err := client.PendingNonceAt(ctx, addr)
	if err != nil {
		return fmt.Errorf("get nonce: %w", err)
	}

	signer := types.LatestSignerForChainID(big.NewInt(112000))

	recipient := common.HexToAddress("0x0EB6dc11D0E4e5BC582541B5DC356a6AD9914230")

	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			gasPrice, err := client.SuggestGasPrice(ctx)
			if err != nil {
				slog.Error("Get gas price", "error", err.Error())
				continue
			}

			tx := types.NewTx(&types.LegacyTx{
				Nonce:    nonce,
				Gas:      cfg.GasLimit,
				GasPrice: gasPrice,
				To:       &recipient,
				Value:    big.NewInt(1),
				Data:     nil,
			})

			signature, err := crypto.Sign(signer.Hash(tx).Bytes(), priv)
			if err != nil {
				slog.Error("Sign tx", "error", err.Error())
				continue
			}

			signedTx, err := tx.WithSignature(signer, signature)
			if err != nil {
				slog.Error("With signature", "error", err.Error())
				continue
			}

			if err := client.SendTransaction(ctx, signedTx); err != nil {
				panic(fmt.Errorf("send tx: %w", err))
			}

			slog.Info("Send tx", "tx", signedTx.Hash().String())

			nonce++
		}
	}
}

func loadConfig() (Config, error) {
	var cfg Config

	if err := cleanenv.ReadEnv(&cfg); err != nil {
		return Config{}, fmt.Errorf("read env: %w", err)
	}

	return cfg, nil
}
