# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Build:**
```
xcodebuild -scheme Sodachi -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**Run all tests:**
```
xcodebuild -scheme Sodachi -destination 'platform=iOS Simulator,name=iPhone 16' test
```

**Run a single test class:**
```
xcodebuild -scheme Sodachi -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:SodachiTests/DecayEngineTests
```

**Run a single test method:**
```
xcodebuild -scheme Sodachi -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:SodachiTests/DecayEngineTests/testHungerDecay
```

No external dependencies — no CocoaPods, no SPM packages.

## Architecture

Sodachi is an iOS virtual pet app (think Tamagotchi). The core loop: pet stats decay over real elapsed time, triggering lifecycle stage transitions and eventually death if neglected.

### Data flow on every app foreground

```
scenePhase → .active
    → DecayEngine.processAll(pets)     // mutates stats in-place
    → LifecycleEngine.evaluateAll(pets) // advances stage if thresholds met
    → context.save()                   // SwiftData persists everything
```

Both engines are **stateless structs** — they receive models and mutate them directly; no delegation, no callbacks.

### Models (`Models/`)

- `Pet` — SwiftData `@Model`, root entity. Owns a `PetStats` child via `.cascade` relationship. Holds `lifecycleStage` and `visualThemeID`.
- `PetStats` — SwiftData `@Model`, all numeric stats (hunger, happiness, health, energy, age, weight). Initialized to starting values (hunger=80, health=100, …).
- `PetLifecycleStage` — `enum` with 7 stages: `egg → baby → child → teen → adult → senior → dead`. Has `isAlive` helper. Stages never regress.

### Services (`Services/`)

- `DecayEngine` — calculates `elapsed = now − pet.lastUpdatedAt`, decays stats proportionally. Secondary cascades: hunger < 20 → health bleeds 5/hr; happiness < 20 → health bleeds 3/hr. Health = 0 → `.dead`. Always updates `lastUpdatedAt`.
- `LifecycleEngine` — reads `stats.age` (in seconds), maps to stage via `LifecycleThresholds`. Only ever advances stage forward; natural death at 15 days regardless of health.
- `DecayRates` — centralized constants for all decay rates and critical thresholds.
- `LifecycleThresholds` — centralized age thresholds (seconds): baby=1hr, child=12hr, teen=48hr, adult=96hr, senior=240hr, naturalDeath=360hr.

### App entry (`SodachiApp.swift`)

Creates the `ModelContainer` for `Pet` (SwiftData cascades to `PetStats` automatically). Watches `scenePhase` and runs decay + lifecycle on every `.active` transition.

### UI (`ContentView.swift`)

Currently a placeholder. Real pet display, actions, and stats UI are not yet implemented.

## Testing

Tests live in `SodachiTests/`. Each test file uses an **in-memory SwiftData container** for isolation — the pattern is:

```swift
container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
context = container.mainContext
```

Tests inject a `now` date into engines to simulate time passage without actually waiting.

Test files map 1:1 to source files: `ModelTests`, `DecayEngineTests`, `LifecycleEngineTests`.

## Open issues

Issues are worked in dependency order. Key contracts defined in issues are noted below so future work stays consistent.

### Visual theme system (#4, #5, #17)
**#4** defines the core protocol — implement this first:
```swift
protocol PetVisualTheme {
    var name: String { get }
    func image(for stage: PetLifecycleStage, state: PetVisualState) -> Image
}
```
Visual states (minimum): `Idle, Eating, Playing, Sleeping, Sick, Dead`. Theme selection is stored per-pet via `Pet.visualThemeID`. Assets are organised per-theme in their own folder/namespace.

**#5** — first concrete implementation: static images for all 7 lifecycle stages × all visual states (placeholders acceptable).

**#17** — `PixelSpriteTheme` stub: conforms to protocol, returns placeholder images, marked "Coming Soon" in the picker.

### Screens (#6, #7, #8)
- **#6 Pet list screen** — lists all pets (name, stage, visual preview); tap to open game screen; separate/marked display for deceased pets; create-new button.
- **#7 Main game screen** — pet display using `PetVisualTheme` + current stage/state; stats HUD (Hunger, Happiness, Health, Energy, Age, Weight); action button area; visual state responds to stats (e.g. sad when happiness low). Depends on #4, #5.
- **#8 Pet creation flow** — name input, theme picker with egg/baby preview, confirm creates pet in SwiftData and navigates to game screen. Depends on #4, #5.

### Actions (#9–#15) — all depend on #7
- **#9 Feed** — meals (restore Hunger, moderate Weight increase) vs snacks (small Hunger, Happiness boost, more Weight). Feeding when full adds Weight with no benefit. Trigger eating visual state.
- **#10 Sleep/lights** — toggle lights off to sleep; Energy recovers over time; blocks other actions while sleeping; trigger sleeping visual state.
- **#11 Play** — define `MiniGame` protocol:
  ```swift
  protocol MiniGame {
      var name: String { get }
      func start()
      var onComplete: (MiniGameResult) -> Void { get set }
  }
  struct MiniGameResult { let won: Bool; let happinessChange: Int }
  ```
  Wire Happiness change on completion; include a stub/mock for testing; no concrete mini-game implementation required here.
- **#12 Clean** — poop accumulates over time (counter/timestamp in model); uncleaned poop degrades Health; Clean action removes all poop; visual indicator when poop present. Decay engine integration needed.
- **#13 Medicine** — restores Health; giving to healthy pet decreases Happiness; trigger sick/medicine visual state.
- **#14 Discipline** — increases discipline/obedience meter when pet misbehaves; unnecessary discipline decreases Happiness; define misbehaviour events (refuses to eat, cries without reason).
- **#15 Toilet** — pet builds toilet need over time; player can proactively send to toilet; accidents create mess and affect Health/Happiness. Decay engine integration needed.

### Notifications (#16)
**#16** — scaffold only (no real notifications): define `NotificationService` protocol (schedule/cancel methods) + no-op `StubNotificationService`. Wire stub into app so a real implementation can be swapped in later.
