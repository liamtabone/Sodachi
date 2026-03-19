# UI Plan — Sodachi

Retro Tamagotchi-inspired aesthetic. Pixel art, chunky borders, limited colour palette, LCD-style feel.

## Status
- [ ] Screen inventory agreed
- [ ] Wireframes drafted
- [ ] Wireframes approved
- [ ] Implementation

---

## Screens

### 1. Main Game Screen
- Central gameplay screen
- **Pet display area** — visual using `PetVisualTheme` based on current stage + state (idle, eating, playing, sleeping, sick, dead)
- **Stats HUD** — Hunger, Happiness, Health, Energy, Age, Weight
- **Action bar** — all actions inline on this screen (no sub-screens):
  - Feed (meal / snack choice inline)
  - Play
  - Sleep / Lights off
  - Clean
  - Medicine
  - Discipline
  - Toilet
- Visual state responds to stats (e.g. sad face when Happiness low, sick animation when Health low)
- Actions disabled during sleep

### 2. Pet Creation Flow
- Shown on first launch when no pet exists
- Name input + species picker
- Confirm → creates pet in SwiftData → app automatically shows Main Game Screen
- Default theme applied automatically (no picker for now)

### 3. Death Screen
- Shown when pet's `lifecycleStage == .dead`
- Memorial display: pet name, age reached, cause of death
- Option to return to Pet List or create a new pet

---

## Future Work
- **Theme Picker screen** — grid/list of themes with preview; reusable in creation flow and settings
- **Settings Screen** — notifications toggle, per-pet theme switching
- **Multi-theme support** — `PetVisualTheme` protocol is already in place; adding new themes requires only a new conforming type and assets, no structural changes needed

---

## Open Questions
- [ ] Does Feed show meal/snack as two buttons on the action bar, or a small inline picker that appears on tap?
- [ ] Does the stats HUD show icons or text labels? (icons more retro)
- [ ] Should the Death Screen be a separate screen or an overlay on the Main Game Screen?
- [ ] Navigation pattern: tab bar, stack navigation, or single-screen with sheets?
