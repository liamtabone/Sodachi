import Foundation

/// Toggles the pet's sleep state. While asleep, energy recovers over time
/// and all other actions are blocked.
struct SleepAction {
    /// Puts the pet to sleep. Does nothing if already asleep, dead, or an egg.
    func putToSleep(pet: Pet) {
        guard let _ = pet.stats, pet.lifecycleStage.isAlive, pet.lifecycleStage != .egg, !pet.isSleeping else { return }
        pet.isSleeping = true
        pet.lastUpdatedAt = .now
    }

    /// Wakes the pet up. Does nothing if already awake.
    func wakeUp(pet: Pet) {
        guard pet.isSleeping else { return }
        pet.isSleeping = false
        pet.lastUpdatedAt = .now
    }
}
