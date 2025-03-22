package vrf

import (
	"crypto/ecdsa"
	"crypto/rand"
	"fmt"

	"github.com/klayoracle/go-ecvrf"
)

type Provider interface {
	GenerateRandomnessWithProof() ([]byte, []byte, error)
}

type provider struct {
	pk *ecdsa.PrivateKey
}

func NewProvider(pk *ecdsa.PrivateKey) Provider {
	return &provider{pk: pk}
}

func (p *provider) GenerateRandomnessWithProof() ([]byte, []byte, error) {
	alpha := make([]byte, 32)
	if _, err := rand.Read(alpha); err != nil {
		return nil, nil, fmt.Errorf("failed to generate alpha: %w", err)
	}

	_, proof, err := ecvrf.Secp256k1Sha256Tai.ProveSecp256k1(p.pk, alpha)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to prove: %w", err)
	}

	return alpha, proof, nil
}
