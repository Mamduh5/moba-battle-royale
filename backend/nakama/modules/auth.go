package modules

import (
	"context"
	"database/sql"

	"github.com/heroiclabs/nakama-common/runtime"
)

func RegisterAuth(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, initializer runtime.Initializer) error {
	return initializer.RegisterRpc("rpc_get_player_profile", rpcGetPlayerProfile)
}

func rpcGetPlayerProfile(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	userID, _ := ctx.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if userID == "" {
		userID = "local-user"
	}
	return `{"user_id":"` + userID + `","display_name":"Player","level":1,"owned_heroes":["hero_guardian","hero_shade","hero_arcanist"],"currencies":{"soft":0,"premium":0}}`, nil
}
