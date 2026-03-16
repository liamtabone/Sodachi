/// Configurable decay rates for the pet stat system.
/// All rate values are per hour. Adjust to tune gameplay feel.
enum DecayRates {
    // MARK: - Primary decay (per hour)
    static let hungerPerHour: Double = 10.0
    static let happinessPerHour: Double = 8.0
    static let energyPerHour: Double = 5.0

    // MARK: - Secondary health decay (per hour, only when critical)
    static let healthPerHourFromHunger: Double = 5.0
    static let healthPerHourFromSadness: Double = 3.0

    // MARK: - Critical thresholds that trigger health decay
    static let criticalHungerThreshold: Double = 20.0
    static let criticalHappinessThreshold: Double = 20.0
}
