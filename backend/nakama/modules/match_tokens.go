package modules

import (
	"context"
	"database/sql"
	"strconv"
	"time"

	"github.com/heroiclabs/nakama-common/runtime"
)

func RegisterMatchTokens(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, initializer runtime.Initializer) error {
	return initializer.RegisterRpc("rpc_issue_match_token", rpcIssueMatchToken)
}

func rpcIssueMatchToken(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	expires := time.Now().Add(time.Hour).UnixMilli()
	return `{"match_id":"local-match","player_id":"player_local","team_id":1,"match_token":"local-dev-token","expires_at_ms":` + strconv.FormatInt(expires, 10) + `,"match_server_host":"127.0.0.1","match_server_port":24560}`, nil
}
