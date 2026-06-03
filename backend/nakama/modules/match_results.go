package modules

import (
	"context"
	"database/sql"

	"github.com/heroiclabs/nakama-common/runtime"
)

func RegisterMatchResults(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, initializer runtime.Initializer) error {
	return initializer.RegisterRpc("rpc_submit_match_result", rpcSubmitMatchResult)
}

func rpcSubmitMatchResult(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	return `{"accepted":true,"reward_grants":{},"leaderboard_updates":["local_results"]}`, nil
}
