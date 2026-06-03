# 24 - Exact Repository Layout

Create and maintain this layout unless the existing repository already has equivalent folders. If an equivalent folder exists, map the contract to the existing names and document the mapping in `docs/PROJECT_LAYOUT_MAPPING.md`.

```text
res://
  project.godot
  autoload/
    GameConfig.gd
    ContentDB.gd
    DebugBus.gd
    Protocol.gd
  shared/
    constants/
      GameConstants.gd
      ProtocolConstants.gd
    content/
      ContentValidator.gd
      ContentLoader.gd
      HeroDef.gd
      AbilityDef.gd
      ModeDef.gd
      MapDef.gd
      BotProfileDef.gd
    net/
      NetworkEnvelope.gd
      NetworkCodec.gd
      NetworkSchemas.gd
      InputFrame.gd
      SnapshotFrame.gd
    simulation/
      SimulationWorld.gd
      SimulationState.gd
      SimulationClock.gd
      SimulationConfig.gd
      EntityId.gd
      EntityRegistry.gd
      TeamService.gd
      DeterministicRng.gd
    movement/
      MovementMotor.gd
      Steering.gd
      CollisionQuery.gd
    combat/
      DamageRequest.gd
      DamageResult.gd
      DamageResolver.gd
      HealthComponent.gd
      DeathResolver.gd
      StatusEffectRuntime.gd
    abilities/
      AbilityRuntime.gd
      AbilityContext.gd
      CooldownTracker.gd
      TargetingResolver.gd
      ProjectileRuntime.gd
      AreaEffectRuntime.gd
    objectives/
      ObjectiveRuntime.gd
      ScoreService.gd
      VictoryResolver.gd
    bots/
      BotBrain.gd
      BotPerception.gd
      BotDecision.gd
      BotInputBuilder.gd
      BotDifficultyProfile.gd
      BotObjectiveSelector.gd
      BotThreatEvaluator.gd
      BotAbilityScorer.gd
  client/
    main/
      ClientApp.gd
    network/
      MatchClient.gd
      PredictionBuffer.gd
      SnapshotInterpolator.gd
      ReconciliationClient.gd
    input/
      InputSampler.gd
      MobileInputAdapter.gd
      KeyboardMouseInputAdapter.gd
    presentation/
      EntityViewBinder.gd
      AbilityVfxRouter.gd
      FloatingTextPresenter.gd
      HealthBarPresenter.gd
    ui/
      screens/
      hud/
      widgets/
    camera/
      ArenaCamera.gd
  server/
    main/
      MatchServerApp.gd
    network/
      MatchServer.gd
      ClientSession.gd
      ServerTransport.gd
      SnapshotEncoder.gd
      ReconciliationService.gd
    match/
      MatchRoom.gd
      MatchLifecycle.gd
      SpawnService.gd
      MatchResultBuilder.gd
      MatchResultReporter.gd
    bots/
      ServerBotManager.gd
    cli/
      HeadlessCommandRouter.gd
  tools/
    cli/
      ValidateContentCommand.gd
      RunTestsCommand.gd
      BotSoakCommand.gd
      ProtocolCheckCommand.gd
      ExportServerCommand.gd
    debug/
      ReplayTraceReader.gd
      SnapshotDiffTool.gd
  tests/
    unit/
    integration/
    protocol/
    soak/
  content/
    heroes/
    abilities/
    modes/
    maps/
    bots/
  scenes/
    client/
      ClientRoot.tscn
      MatchScene.tscn
    server/
      ServerRoot.tscn
    prefabs/
      HeroActor.tscn
      ProjectileActor.tscn
      ObjectiveActor.tscn
    ui/
      HUD.tscn
      MainMenu.tscn
  addons/
```

## Ownership rules

### `shared/`

`shared/` must not depend on client UI, client camera, client VFX, or server socket transport. It may contain data models, simulation rules, combat rules, ability rules, bot decision logic, and protocol models.

### `client/`

`client/` may render, predict, interpolate, sample input, show UI, and send input frames. It must not decide authoritative damage, cooldown reset, objective capture, score, reward, or match result.

### `server/`

`server/` owns authoritative match state. It receives validated player input, advances the simulation tick, runs bots, builds snapshots, acknowledges input, emits combat/objective events, and reports match results to Nakama.

### `content/`

`content/` contains production game data. Do not hard-code hero stats or ability numbers in scripts except test fixtures.

### `tools/cli/`

All custom command-line commands live here. Godot custom flags must be parsed from `OS.get_cmdline_user_args()` after the `--` separator.

## Required autoloads

Configure these in `project.godot`:

```text
GameConfig=res://autoload/GameConfig.gd
ContentDB=res://autoload/ContentDB.gd
DebugBus=res://autoload/DebugBus.gd
Protocol=res://autoload/Protocol.gd
```

Autoloads must be small facades. Do not put large gameplay systems inside autoloads.

## Dependency direction

Allowed:

```text
client -> shared
server -> shared
server -> server/match
client -> client/presentation
client/ui -> client/network readonly state facades
```

Forbidden:

```text
shared -> client
shared -> server
server -> client
combat -> ui
abilities -> ui
bots -> ui
```

## Scene rule

Scenes are composition files. Business rules live in scripts under `shared/`, `client/`, or `server/`.

A `.tscn` file may wire nodes and exported references. It must not be the only place where important gameplay behavior exists.
