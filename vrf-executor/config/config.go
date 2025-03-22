package config

import (
	"fmt"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ilyakaznacheev/cleanenv"
)

type Config struct {
	RPC            string         `yaml:"rpc" env:"RPC" env-required:"true"`
	PrivateKey     string         `yaml:"private_key" env:"PRIVATE_KEY" env-required:"true"`
	VRFCore        common.Address `yaml:"vrf_core" env:"VRF_CORE" env-required:"true"`
	BlocksInterval time.Duration  `yaml:"blocks_interval" env:"BLOCKS_INTERVAL" env-default:"2s"`
	ChainID        uint64         `yaml:"chain_id" env:"CHAIN_ID" env-required:"true"`
	// Temp Relayer configuration
	Relayer struct {
		Enabled    bool          `yaml:"enable" env:"RELAYER_ENABLED" env-default:"false"`
		Interval   time.Duration `yaml:"interval" env:"RELAYER_INTERVAL" env-default:"5s"`
		PrivateKey string        `yaml:"private_key" env:"RELAYER_PRIVATE_KEY"`
	}
}

func LoadConfig() (Config, error) {
	var cfg Config

	if err := cleanenv.ReadEnv(&cfg); err != nil {
		return Config{}, fmt.Errorf("read env: %w", err)
	}

	return cfg, nil
}
