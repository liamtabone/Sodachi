import Foundation

/// Applies the result of a completed mini-game to the pet's Happiness.
///
/// Win/loss happiness deltas are defined by the `MiniGameResult`.
/// Sleeping or inactive pets are not affected.
struct PlayAction {
    func play(pet: Pet, result: MiniGameResult) {
        guard let stats = pet.stats,
              pet.lifecycleStage.isAlive,
              pet.lifecycleStage != .egg,
              !pet.isSleeping else { return }

        stats.happiness = max(0, min(100, stats.happiness + result.happinessChange))
        pet.lastUpdatedAt = .now
    }
}
