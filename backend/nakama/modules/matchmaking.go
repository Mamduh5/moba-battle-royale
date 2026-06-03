package modules

import (
	"context"
	"database/sql"

	"github.com/heroiclabs/nakama-common/runtime"
)

func RegisterMatchmaking(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, initializer runtime.Initializer) error {
	if err := initializer.RegisterRpc("rpc_start_matchmaking", rpcStartMatchmaking); err != nil {
		return err
	}
	return initializer.RegisterRpc("rpc_cancel_matchmaking", rpcCancelMatchmaking)
}

func rpcStartMatchmaking(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	return `{"ticket":"local-ticket"}`, nil
}

func rpcCancelMatchmaking(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	return `{"cancelled":true}`, nil
}
