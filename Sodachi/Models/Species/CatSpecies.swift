/// Independent and self-sufficient. Slower decay rates and a longer lifespan.
struct CatSpecies: PetSpecies {
    static let speciesID = "cat"
    var speciesID: String { CatSpecies.speciesID }
    var displayName: String { "Cat" }

    var decayRates: SpeciesDecayRates {
        SpeciesDecayRates(
            hungerPerHour: 8.0,
            happinessPerHour: 5.0,
            energyPerHour: 4.0,
            energyRecoveryPerHour: 20.0,
            healthPerHourFromHunger: 4.0,
            healthPerHourFromSadness: 2.0,
            criticalHungerThreshold: 20.0,
            criticalHappinessThreshold: 20.0
        )
    }

    var lifecycleThresholds: SpeciesLifecycleThresholds {
        SpeciesLifecycleThresholds(
            baby:         900,        // 15 minutes
            child:        57_600,     // 16 hours
            teen:         216_000,    // 60 hours
            adult:        432_000,    // 120 hours (5 days)
            senior:       1_080_000,  // 300 hours (~12.5 days)
            naturalDeath: 1_620_000   // 450 hours (~18.75 days)
        )
    }

    var startingStats: SpeciesStartingStats {
        SpeciesStartingStats(hunger: 75, happiness: 70, health: 100, energy: 100, weight: 40)
    }
}
