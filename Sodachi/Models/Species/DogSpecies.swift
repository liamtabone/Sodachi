/// Eager and energetic. Hungers quickly, but also bonds fast.
/// Faster lifecycle than a cat.
struct DogSpecies: PetSpecies {
    static let speciesID = "dog"
    var speciesID: String { DogSpecies.speciesID }
    var displayName: String { "Dog" }

    var decayRates: SpeciesDecayRates {
        SpeciesDecayRates(
            hungerPerHour: 12.0,
            happinessPerHour: 10.0,
            energyPerHour: 6.0,
            healthPerHourFromHunger: 5.0,
            healthPerHourFromSadness: 3.0,
            criticalHungerThreshold: 20.0,
            criticalHappinessThreshold: 20.0
        )
    }

    var lifecycleThresholds: SpeciesLifecycleThresholds {
        SpeciesLifecycleThresholds(
            baby:         900,        // 15 minutes
            child:        36_000,     // 10 hours
            teen:         144_000,    // 40 hours
            adult:        288_000,    // 80 hours (~3.3 days)
            senior:       720_000,    // 200 hours (~8.3 days)
            naturalDeath: 1_080_000   // 300 hours (~12.5 days)
        )
    }

    var startingStats: SpeciesStartingStats {
        SpeciesStartingStats(hunger: 80, happiness: 90, health: 100, energy: 100, weight: 45)
    }
}
