import Foundation

/// Age thresholds (in seconds) that trigger lifecycle stage transitions.
/// Adjust to tune how quickly a pet progresses through its life.
enum LifecycleThresholds {
    static let baby: TimeInterval        = 3_600       // 1 hour
    static let child: TimeInterval       = 43_200      // 12 hours
    static let teen: TimeInterval        = 172_800     // 48 hours
    static let adult: TimeInterval       = 345_600     // 96 hours  (4 days)
    static let senior: TimeInterval      = 864_000     // 240 hours (10 days)
    static let naturalDeath: TimeInterval = 1_296_000  // 360 hours (15 days)
}

struct LifecycleEngine {
    /// Evaluates a single pet's age and advances its lifecycle stage if thresholds are met.
    /// Dead pets are skipped. Stage only ever moves forward.
    func evaluate(pet: Pet) {
        guard pet.lifecycleStage.isAlive, let stats = pet.stats else { return }

        let age = stats.age

        let newStage: PetLifecycleStage
        switch age {
        case LifecycleThresholds.naturalDeath...:
            newStage = .dead
        case LifecycleThresholds.senior...:
            newStage = .senior
        case LifecycleThresholds.adult...:
            newStage = .adult
        case LifecycleThresholds.teen...:
            newStage = .teen
        case LifecycleThresholds.child...:
            newStage = .child
        case LifecycleThresholds.baby...:
            newStage = .baby
        default:
            newStage = .egg
        }

        // Only advance — never regress a stage
        if stageIndex(newStage) > stageIndex(pet.lifecycleStage) {
            pet.lifecycleStage = newStage
        }
    }

    /// Evaluates all pets. Call after `DecayEngine.processAll` on each app launch.
    func evaluateAll(pets: [Pet]) {
        for pet in pets {
            evaluate(pet: pet)
        }
    }

    // MARK: - Private

    private func stageIndex(_ stage: PetLifecycleStage) -> Int {
        switch stage {
        case .egg:    return 0
        case .baby:   return 1
        case .child:  return 2
        case .teen:   return 3
        case .adult:  return 4
        case .senior: return 5
        case .dead:   return 6
        }
    }
}
