package transactor

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log/slog"
	"math/big"

	"github.com/avelex/random-network/vrf-executor/abi"
	"github.com/ethereum/go-ethereum/accounts"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

type Transactor interface {
	ExecuteVRF(ctx context.Context, requestID [32]byte, randomness []byte, proof []byte) error
	RequestVRF(ctx context.Context, requestID [32]byte, sourceChainID *big.Int, requester common.Address, parameters []byte) error
}

type transactor struct {
	pk       *ecdsa.PrivateKey
	client   *ethclient.Client
	chainID  *big.Int
	opts     *bind.TransactOpts
	contract *abi.VRFCoreTransactor
}

func New(pk *ecdsa.PrivateKey, client *ethclient.Client, chainID *big.Int, contract *abi.VRFCoreTransactor) (*transactor, error) {
	opts, err := bind.NewKeyedTransactorWithChainID(pk, chainID)
	if err != nil {
		return nil, fmt.Errorf("failed to create transactor: %w", err)
	}

	nonce, err := client.PendingNonceAt(context.Background(), opts.From)
	if err != nil {
		return nil, fmt.Errorf("failed to get nonce: %w", err)
	}

	opts.Nonce = big.NewInt(int64(nonce))

	return &transactor{
		pk:       pk,
		client:   client,
		chainID:  chainID,
		opts:     opts,
		contract: contract,
	}, nil
}

func (t *transactor) ExecuteVRF(ctx context.Context, requestID [32]byte, randomness []byte, proof []byte) error {
	sig, err := t.signVRF(requestID, randomness, proof)
	if err != nil {
		return fmt.Errorf("failed to sign VRF: %w", err)
	}

	gasPrice, err := t.client.SuggestGasPrice(ctx)
	if err != nil {
		return fmt.Errorf("failed to get gas price: %w", err)
	}

	t.opts.GasPrice = gasPrice
	// TODO: set gas limit

	tx, err := t.contract.ExecuteVRF(t.opts, requestID, t.pubKeyForRequest(), randomness, proof, sig)
	if err != nil {
		return fmt.Errorf("failed to execute VRF: %w", err)
	}

	slog.Info("Sent VRF Execute transaction", "tx", tx.Hash())

	t.opts.Nonce.Add(t.opts.Nonce, big.NewInt(1))

	return nil
}

func (t *transactor) RequestVRF(ctx context.Context, requestID [32]byte, sourceChainID *big.Int, requester common.Address, parameters []byte) error {
	gasPrice, err := t.client.SuggestGasPrice(ctx)
	if err != nil {
		return fmt.Errorf("failed to get gas price: %w", err)
	}

	t.opts.GasPrice = gasPrice

	tx, err := t.contract.HandleCrossChainRequest(t.opts, requestID, sourceChainID, requester, parameters)
	if err != nil {
		return fmt.Errorf("failed to request VRF: %w", err)
	}

	slog.Info("Sent VRF Request transaction", "tx", tx.Hash())

	t.opts.Nonce.Add(t.opts.Nonce, big.NewInt(1))

	return nil
}

func (t *transactor) pubKeyForRequest() [2]*big.Int {
	return [2]*big.Int{t.pk.PublicKey.X, t.pk.PublicKey.Y}
}

func (t *transactor) signVRF(requestID [32]byte, randomness []byte, proof []byte) ([]byte, error) {
	hashed := crypto.Keccak256Hash(
		requestID[:],
		randomness,
		proof,
	)

	ethMsgHashed := accounts.TextHash(hashed[:])

	sig, err := crypto.Sign(ethMsgHashed, t.pk)
	if err != nil {
		return nil, fmt.Errorf("failed to sign: %w", err)
	}

	// The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
	// this function rejects them by requiring the `s` value to be in the lower
	// half order, and the `v` value to be either 27 or 28.
	sig[64] += 27

	return sig, nil
}
