import Foundation

/// Administers medicine to the pet, restoring Health.
///
/// Giving medicine to a healthy pet has a happiness penalty —
/// the pet dislikes unnecessary medication.
struct MedicineAction {
    static let healthRestore: Double = 30
    /// Health threshold above which medicine is considered unnecessary.
    static let healthyThreshold: Double = 80
    static let unnecessaryHappinessPenalty: Double = 10

    func administer(pet: Pet) {
        guard let stats = pet.stats,
              pet.lifecycleStage.isAlive,
              pet.lifecycleStage != .egg,
              !pet.isSleeping else { return }

        if stats.health >= Self.healthyThreshold {
            stats.happiness = max(0, stats.happiness - Self.unnecessaryHappinessPenalty)
        }
        stats.health = min(100, stats.health + Self.healthRestore)
        pet.lastUpdatedAt = .now
    }
}
