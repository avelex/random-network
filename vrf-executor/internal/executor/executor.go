package executor

import (
	"context"
	"log/slog"

	vrfcore "github.com/avelex/random-network/vrf-executor/internal/listeners/vrf_core"
	"github.com/avelex/random-network/vrf-executor/internal/transactor"
	"github.com/avelex/random-network/vrf-executor/internal/vrf"
	"github.com/ethereum/go-ethereum/common/hexutil"
)

type Executor struct {
	listener    vrfcore.Listener
	vrfProvider vrf.Provider
	transactor  transactor.Transactor
}

func New(listener vrfcore.Listener, vrfProvider vrf.Provider, tr transactor.Transactor) *Executor {
	return &Executor{
		listener:    listener,
		vrfProvider: vrfProvider,
		transactor:  tr,
	}
}

func (e *Executor) Run(ctx context.Context) error {
	for {
		select {
		case <-ctx.Done():
			return nil
		case reqID, ok := <-e.listener.ListenRequests(ctx):
			if !ok {
				return nil
			}

			reqLog := slog.With("request_id", hexutil.Encode(reqID[:]))
			reqLog.Info("New request received")

			randomness, proof, err := e.vrfProvider.GenerateRandomnessWithProof()
			if err != nil {
				reqLog.Error("Failed to generate randomness", "error", err)
				continue
			}

			reqLog.Info("VRF generated")

			if err = e.transactor.ExecuteVRF(ctx, reqID, randomness, proof); err != nil {
				reqLog.Error("Failed to execute VRF", "error", err)
				continue
			}

			reqLog.Info("VRF executed")
		}
	}
}
