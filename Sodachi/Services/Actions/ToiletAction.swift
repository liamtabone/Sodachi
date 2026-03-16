import Foundation

/// Sends the pet to the toilet, resetting toilet need before an accident occurs.
///
/// Toilet need accumulates over time in `DecayEngine`. If it reaches 100 an
/// accident happens automatically (poop added, health/happiness penalty).
/// Using this action proactively prevents accidents.
struct ToiletAction {
    func use(pet: Pet) {
        guard let stats = pet.stats,
              pet.lifecycleStage.isAlive,
              pet.lifecycleStage != .egg,
              !pet.isSleeping else { return }

        stats.toiletNeed = 0
        pet.lastUpdatedAt = .now
    }
}
