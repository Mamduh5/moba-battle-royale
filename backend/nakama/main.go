package main

import (
	"context"
	"database/sql"

	"arena-royale-nakama/modules"
	"github.com/heroiclabs/nakama-common/runtime"
)

func InitModule(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, initializer runtime.Initializer) error {
	if err := modules.RegisterAuth(ctx, logger, db, nk, initializer); err != nil {
		return err
	}
	if err := modules.RegisterMatchmaking(ctx, logger, db, nk, initializer); err != nil {
		return err
	}
	if err := modules.RegisterMatchTokens(ctx, logger, db, nk, initializer); err != nil {
		return err
	}
	if err := modules.RegisterMatchResults(ctx, logger, db, nk, initializer); err != nil {
		return err
	}
	modules.RegisterProgression(ctx, logger, db, nk, initializer)
	modules.RegisterInventory(ctx, logger, db, nk, initializer)
	modules.RegisterLeaderboards(ctx, logger, db, nk, initializer)
	modules.RegisterParties(ctx, logger, db, nk, initializer)
	modules.RegisterAdminDebug(ctx, logger, db, nk, initializer)
	logger.Info("arena royale nakama module registered")
	return nil
}
