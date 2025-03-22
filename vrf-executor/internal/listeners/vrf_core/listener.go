package vrfcore

import (
	"context"

	"github.com/avelex/random-network/vrf-executor/abi"
	"github.com/avelex/random-network/vrf-executor/internal/listeners/blocks"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
)

type RequestID [32]byte

type Listener interface {
	ListenRequests(ctx context.Context) <-chan RequestID
}

type listener struct {
	requests      chan RequestID
	contract      *abi.VRFCoreFilterer
	blockListener blocks.Listener
}

func NewListener(blockListener blocks.Listener, contract *abi.VRFCoreFilterer) *listener {
	return &listener{
		requests:      make(chan RequestID),
		contract:      contract,
		blockListener: blockListener,
	}
}

func (l *listener) Start(ctx context.Context) {
	for br := range l.blockListener.Listen(ctx) {
		opts := &bind.FilterOpts{
			Context: ctx,
			Start:   br.From,
			End:     &br.To,
		}

		iter, err := l.contract.FilterRequestReceived(opts, nil)
		if err != nil {
			continue
		}

		for iter.Next() {
			l.requests <- iter.Event.RequestId
		}

		if err := iter.Close(); err != nil {
			continue
		}
	}

	close(l.requests)
}

func (l *listener) ListenRequests(ctx context.Context) <-chan RequestID {
	return l.requests
}
