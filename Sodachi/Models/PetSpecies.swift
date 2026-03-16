import Foundation

// MARK: - Value types

struct SpeciesDecayRates {
    /// Per hour
    let hungerPerHour: Double
    /// Per hour
    let happinessPerHour: Double
    /// Per hour (only when awake)
    let energyPerHour: Double
    /// Per hour (only when sleeping)
    let energyRecoveryPerHour: Double
    /// Per hour, applied when hunger is below criticalHungerThreshold
    let healthPerHourFromHunger: Double
    /// Per hour, applied when happiness is below criticalHappinessThreshold
    let healthPerHourFromSadness: Double
    let criticalHungerThreshold: Double
    let criticalHappinessThreshold: Double
    /// Poop piles added per hour naturally (fractional, accumulated internally)
    let poopRatePerHour: Double
    /// Health lost per poop pile per hour
    let healthDecayPerPoopPerHour: Double
    /// Toilet need added per hour (0–100 scale)
    let toiletNeedPerHour: Double
}

struct SpeciesLifecycleThresholds {
    /// Age in seconds at which the pet hatches from egg to baby
    let baby: TimeInterval
    let child: TimeInterval
    let teen: TimeInterval
    let adult: TimeInterval
    let senior: TimeInterval
    /// Age in seconds at which the pet dies of old age
    let naturalDeath: TimeInterval
}

struct SpeciesStartingStats {
    let hunger: Double
    let happiness: Double
    let health: Double
    let energy: Double
    let weight: Double
}

// MARK: - Protocol

protocol PetSpecies {
    var speciesID: String { get }
    var displayName: String { get }
    var decayRates: SpeciesDecayRates { get }
    var lifecycleThresholds: SpeciesLifecycleThresholds { get }
    var startingStats: SpeciesStartingStats { get }
}
