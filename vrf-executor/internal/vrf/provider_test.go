package vrf_test

import (
	"math/big"
	"testing"

	"github.com/avelex/random-network/vrf-executor/abi"
	"github.com/avelex/random-network/vrf-executor/internal/vrf"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient/simulated"
	"github.com/ethereum/go-ethereum/params"
	"github.com/klayoracle/go-ecvrf"
	"github.com/stretchr/testify/require"
)

func Test_GenerateRandomnessWithProof(t *testing.T) {
	r := require.New(t)

	pk, err := crypto.GenerateKey()
	r.NoError(err)

	provider := vrf.NewProvider(pk)

	randomness, proof, err := provider.GenerateRandomnessWithProof()
	r.NoError(err)
	r.NotNil(randomness)
	r.NotNil(proof)

	pub := pk.PublicKey

	_, err = ecvrf.Secp256k1Sha256Tai.VerifySecp256k1(&pub, randomness, proof)
	r.NoError(err)
}

func Test_Blockchain_Simulation(t *testing.T) {
	r := require.New(t)

	privateKey, err := crypto.GenerateKey()
	r.NoError(err)

	owner := crypto.PubkeyToAddress(privateKey.PublicKey)
	blockchain := newBlockchain(owner)
	blockchain.Commit()

	txOpts, err := bind.NewKeyedTransactorWithChainID(privateKey, big.NewInt(1337))
	r.NoError(err)

	_, _, vrfLib, err := abi.DeployVRFVerificationLib(txOpts, blockchain.Client())
	r.NoError(err)

	blockchain.Commit()

	provider := vrf.NewProvider(privateKey)
	rand, proof, err := provider.GenerateRandomnessWithProof()
	r.NoError(err)

	publicKey := [2]*big.Int{privateKey.PublicKey.X, privateKey.PublicKey.Y}

	verified, err := vrfLib.Verify(nil, publicKey, proof, rand)
	r.NoError(err)
	r.True(verified)
}

func newBlockchain(owner common.Address) *simulated.Backend {
	return simulated.NewBackend(types.GenesisAlloc{
		owner: {Balance: big.NewInt(params.Ether)},
	})
}
