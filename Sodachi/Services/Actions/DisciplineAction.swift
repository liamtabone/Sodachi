import Foundation

/// Disciplines the pet.
///
/// - When the pet is misbehaving: raises the discipline/obedience meter and
///   clears the misbehaving flag.
/// - When the pet is not misbehaving: decreases Happiness (unnecessary discipline).
struct DisciplineAction {
    static let disciplineGain: Double = 15
    static let unnecessaryHappinessPenalty: Double = 15

    func discipline(pet: Pet) {
        guard let stats = pet.stats,
              pet.lifecycleStage.isAlive,
              pet.lifecycleStage != .egg,
              !pet.isSleeping else { return }

        if pet.isMisbehaving {
            stats.discipline = min(100, stats.discipline + Self.disciplineGain)
            pet.isMisbehaving = false
        } else {
            stats.happiness = max(0, stats.happiness - Self.unnecessaryHappinessPenalty)
        }
        pet.lastUpdatedAt = .now
    }
}
