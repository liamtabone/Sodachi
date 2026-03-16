import Foundation

/// Removes all poop piles from the pet's environment.
/// Uncleaned poop degrades Health over time; regular cleaning prevents this.
struct CleanAction {
    func clean(pet: Pet) {
        guard pet.lifecycleStage.isAlive, pet.lifecycleStage != .egg, !pet.isSleeping else { return }
        pet.poopCount = 0
        pet.lastUpdatedAt = .now
    }
}
