package main

import (
	"context"
	"fmt"
	"log/slog"
	"math/big"
	"os"
	"os/signal"
	"time"

	"github.com/avelex/random-network/vrf-executor/abi"
	"github.com/avelex/random-network/vrf-executor/config"
	"github.com/avelex/random-network/vrf-executor/internal/executor"
	"github.com/avelex/random-network/vrf-executor/internal/listeners/blocks"
	vrfcore "github.com/avelex/random-network/vrf-executor/internal/listeners/vrf_core"
	"github.com/avelex/random-network/vrf-executor/internal/transactor"
	"github.com/avelex/random-network/vrf-executor/internal/vrf"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/lmittmann/tint"
)

func main() {
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	// set global logger with custom options
	slog.SetDefault(slog.New(
		tint.NewHandler(os.Stderr, &tint.Options{
			Level:      slog.LevelDebug,
			TimeFormat: time.DateTime,
		}),
	))

	slog.Info("VRF-Executor initializing")

	if err := run(ctx); err != nil {
		slog.Error("Failed to run", "error", err)
	}

	slog.Info("VRF-Executor stopped")
}

func run(ctx context.Context) error {
	cfg, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("load config: %w", err)
	}

	slog.Info("Config loaded")

	client, err := ethclient.DialContext(ctx, cfg.RPC)
	if err != nil {
		return fmt.Errorf("dial eth client: %w", err)
	}

	defer client.Close()

	slog.Info("Eth client connected", "rpc", cfg.RPC)

	contract, err := abi.NewVRFCore(cfg.VRFCore, client)
	if err != nil {
		return fmt.Errorf("create vrf core contract: %w", err)
	}

	slog.Info("VRF Core contract instance initialized", "address", cfg.VRFCore)

	privateKey, err := crypto.HexToECDSA(cfg.PrivateKey)
	if err != nil {
		return fmt.Errorf("create private key: %w", err)
	}

	execTrx, err := transactor.New(privateKey, client, big.NewInt(int64(cfg.ChainID)), &contract.VRFCoreTransactor)
	if err != nil {
		return fmt.Errorf("create transactor: %w", err)
	}

	vrfProvider := vrf.NewProvider(privateKey)

	blocksListener := blocks.NewListener(client, cfg.BlocksInterval)
	vrfcoreListener := vrfcore.NewListener(blocksListener, &contract.VRFCoreFilterer)

	slog.Info("Start blocks listener", "interval", cfg.BlocksInterval)
	go blocksListener.Start(ctx)

	slog.Info("Start VRF Core listener", "vrf_core", cfg.VRFCore)
	go vrfcoreListener.Start(ctx)

	exec := executor.New(vrfcoreListener, vrfProvider, execTrx)

	slog.Info("Start VRF-Executor", "address", crypto.PubkeyToAddress(privateKey.PublicKey))

	if cfg.Relayer.Enabled {
		relayerPrivateKey, err := crypto.HexToECDSA(cfg.Relayer.PrivateKey)
		if err != nil {
			return fmt.Errorf("create relayer private key: %w", err)
		}

		relayerTrx, err := transactor.New(relayerPrivateKey, client, big.NewInt(int64(cfg.ChainID)), &contract.VRFCoreTransactor)
		if err != nil {
			return fmt.Errorf("create relayer transactor: %w", err)
		}

		relayer := executor.NewRelayer(cfg, relayerTrx)

		slog.Info("Start relayer", "interval", cfg.Relayer.Interval)

		relayer.Start(ctx)
	}

	return exec.Run(ctx)
}
