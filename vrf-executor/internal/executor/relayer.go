package executor

import (
	"context"
	"crypto/rand"
	"log/slog"
	"math/big"
	"time"

	"github.com/avelex/random-network/vrf-executor/config"
	"github.com/avelex/random-network/vrf-executor/internal/transactor"
	"github.com/ethereum/go-ethereum/common"
)

type Relayer struct {
	cfg        config.Config
	transactor transactor.Transactor
}

func NewRelayer(cfg config.Config, tr transactor.Transactor) *Relayer {
	return &Relayer{
		cfg:        cfg,
		transactor: tr,
	}
}

func (r *Relayer) Start(ctx context.Context) {
	ticker := time.NewTicker(r.cfg.Relayer.Interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			requestBody := make([]byte, 32)
			rand.Read(requestBody)

			if err := r.transactor.RequestVRF(ctx, [32]byte(requestBody), big.NewInt(1), common.BytesToAddress(requestBody), requestBody); err != nil {
				slog.Error("Failed to request VRF", "error", err)
			}
		}
	}
}
