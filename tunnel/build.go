//go:build windows

package tunnel

import (
	"context"
	"time"

	"github.com/fosrl/newt/logger"

	olmpkg "github.com/fosrl/olm/olm"
)

// buildTunnel builds the tunnel
func buildTunnel(config Config) error {
	logger.Debug("Build tunnel called: config: %+v", config)

	// Create context for OLM
	olmContext := context.Background()

	// Create OLM GlobalConfig with hardcoded values from Swift
	olmInitConfig := olmpkg.GlobalConfig{
		LogLevel:   "debug",
		EnableAPI:  false,
		SocketPath: "/var/run/olm.sock",
		Version:    "1",
		OnConnected: func() {
			logger.Info("OLM connected")
		},
		OnRegistered: func() {
			logger.Info("OLM disconnected")
		},
	}

	// Initialize OLM with context and GlobalConfig
	olmpkg.Init(olmContext, olmInitConfig)

	olmConfig := olmpkg.TunnelConfig{
		Endpoint:             config.Endpoint,
		ID:                   config.ID,
		Secret:               config.Secret,
		MTU:                  config.MTU,
		DNS:                  config.DNS,
		Holepunch:            config.Holepunch,
		PingIntervalDuration: time.Duration(config.PingIntervalSeconds) * time.Second,
		PingTimeoutDuration:  time.Duration(config.PingTimeoutSeconds) * time.Second,
		UserToken:            config.UserToken,
		OrgID:                config.OrgID,
	}

	logger.Info("Starting OLM tunnel...")
	go func() {
		olmpkg.StartTunnel(olmConfig)
		logger.Info("OLM tunnel stopped")
	}()

	logger.Debug("Build tunnel completed successfully")
	return nil
}
