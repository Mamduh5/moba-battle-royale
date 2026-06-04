package main

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/heroiclabs/nakama-common/runtime"
)

func InitModule(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, initializer runtime.Initializer) error {
	if err := initializer.RegisterRpc("rpc_get_player_profile", rpcGetPlayerProfile); err != nil {
		return err
	}
	if err := initializer.RegisterRpc("rpc_issue_match_token", rpcIssueMatchToken); err != nil {
		return err
	}
	if err := initializer.RegisterRpc("rpc_submit_match_result", rpcSubmitMatchResult); err != nil {
		return err
	}
	if err := initializer.RegisterRpc("rpc_start_matchmaking", rpcStartMatchmaking); err != nil {
		return err
	}
	return initializer.RegisterRpc("rpc_cancel_matchmaking", rpcCancelMatchmaking)
}

func rpcGetPlayerProfile(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	userID, _ := ctx.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if userID == "" {
		userID = "local-dev-user"
	}
	out := map[string]any{
		"user_id":      userID,
		"display_name": "Arena Player",
		"level":        1,
		"owned_heroes": []string{"hero_guardian", "hero_raptor", "hero_oracle"},
		"currencies":   map[string]int{"soft": 0, "premium": 0},
	}
	bytes, err := json.Marshal(out)
	return string(bytes), err
}

func rpcStartMatchmaking(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	out := map[string]any{"ticket": "local-dev-ticket"}
	bytes, err := json.Marshal(out)
	return string(bytes), err
}

func rpcCancelMatchmaking(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	out := map[string]any{"cancelled": true}
	bytes, err := json.Marshal(out)
	return string(bytes), err
}

func rpcIssueMatchToken(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var input map[string]any
	_ = json.Unmarshal([]byte(payload), &input)
	out := map[string]any{
		"match_id":            input["match_id"],
		"player_id":           input["player_id"],
		"team_id":             input["team_id"],
		"match_token":         "local-dev-token-not-for-production",
		"expires_at_ms":       4102444800000,
		"match_server_host":   "127.0.0.1",
		"match_server_port":   24560,
	}
	bytes, err := json.Marshal(out)
	return string(bytes), err
}

func rpcSubmitMatchResult(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	out := map[string]any{
		"accepted":            true,
		"reward_grants":       map[string]any{},
		"leaderboard_updates": []string{"arena_3v3_ranked_kills"},
	}
	bytes, err := json.Marshal(out)
	return string(bytes), err
}
