import Foundation

/// Handles feeding a pet a meal or a snack.
///
/// - Meal: significantly restores Hunger, moderately increases Weight.
/// - Snack: slightly restores Hunger, boosts Happiness, increases Weight more than a meal.
///
/// Weight always increases regardless of current Hunger level — feeding a full pet
/// only adds weight with no nutritional benefit.
struct FeedAction {
    enum FoodType: String, CaseIterable {
        case meal  = "Meal"
        case snack = "Snack"
    }

    /// Applies feeding effects to `pet`. Does nothing if the pet is dead or has no stats.
    func feed(pet: Pet, foodType: FoodType) {
        guard let stats = pet.stats, pet.lifecycleStage.isAlive, pet.lifecycleStage != .egg, !pet.isSleeping else { return }

        switch foodType {
        case .meal:
            stats.hunger = min(100, stats.hunger + 30)
            stats.weight += 1.0
        case .snack:
            stats.hunger  = min(100, stats.hunger + 10)
            stats.happiness = min(100, stats.happiness + 10)
            stats.weight += 2.0
        }

        pet.lastUpdatedAt = .now
    }
}
