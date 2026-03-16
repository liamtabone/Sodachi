import SwiftData
import Foundation

@Model
final class Pet {
    var name: String
    var species: String
    var createdAt: Date
    /// Updated after every decay pass or stat-changing action.
    var lastUpdatedAt: Date
    var lifecycleStage: PetLifecycleStage
    var visualThemeID: String
    var isSleeping: Bool

    @Relationship(deleteRule: .cascade)
    var stats: PetStats?

    /// The visual state to display based on current stats and lifecycle stage.
    var visualState: PetVisualState {
        guard let stats, lifecycleStage.isAlive else { return .dead }
        if isSleeping { return .sleeping }
        if stats.health < 30 { return .sick }
        return .idle
    }

    init(
        name: String,
        species: String = DogSpecies.speciesID,
        visualThemeID: String = "static"
    ) {
        self.name = name
        self.species = species
        self.createdAt = .now
        self.lastUpdatedAt = .now
        self.lifecycleStage = .egg
        self.visualThemeID = visualThemeID
        self.isSleeping = false
        let s = SpeciesRegistry.species(for: species).startingStats
        self.stats = PetStats(
            hunger: s.hunger,
            happiness: s.happiness,
            health: s.health,
            energy: s.energy,
            weight: s.weight
        )
    }
}
