import Foundation

struct LifecycleEngine {
    /// Evaluates a single pet's age and advances its lifecycle stage if thresholds are met.
    /// Dead pets are skipped. Stage only ever moves forward.
    func evaluate(pet: Pet) {
        guard pet.lifecycleStage.isAlive, let stats = pet.stats else { return }

        let age = stats.age
        let thresholds = SpeciesRegistry.species(for: pet.species).lifecycleThresholds

        let newStage: PetLifecycleStage
        switch age {
        case thresholds.naturalDeath...:
            newStage = .dead
        case thresholds.senior...:
            newStage = .senior
        case thresholds.adult...:
            newStage = .adult
        case thresholds.teen...:
            newStage = .teen
        case thresholds.child...:
            newStage = .child
        case thresholds.baby...:
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
