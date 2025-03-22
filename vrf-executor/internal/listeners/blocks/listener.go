package blocks

import (
	"context"
	"log/slog"
	"time"

	"github.com/ethereum/go-ethereum/ethclient"
)

type Listener interface {
	Listen(ctx context.Context) <-chan Range
}

type listener struct {
	blocks   chan Range
	interval time.Duration
	client   *ethclient.Client
}

func NewListener(client *ethclient.Client, interval time.Duration) *listener {
	return &listener{
		blocks:   make(chan Range),
		interval: interval,
		client:   client,
	}
}

func (l *listener) Start(ctx context.Context) {
	defer close(l.blocks)

	ticker := time.NewTicker(l.interval)
	defer ticker.Stop()

	lastBlockNumber := uint64(0)

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			currentBlockNumber, err := l.client.BlockNumber(ctx)
			if err != nil {
				continue
			}

			if lastBlockNumber == 0 {
				lastBlockNumber = currentBlockNumber
			}

			if lastBlockNumber == currentBlockNumber {
				continue
			}

			from := lastBlockNumber
			to := currentBlockNumber - 1

			slog.Debug("New blocks", "from", from, "to", to)

			l.blocks <- Range{
				From: from,
				To:   to,
			}

			lastBlockNumber = currentBlockNumber
		}
	}
}

func (l *listener) Listen(ctx context.Context) <-chan Range {
	return l.blocks
}
