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

    @Relationship(deleteRule: .cascade)
    var stats: PetStats?

    init(
        name: String,
        species: String = "default",
        visualThemeID: String = "static"
    ) {
        self.name = name
        self.species = species
        self.createdAt = .now
        self.lastUpdatedAt = .now
        self.lifecycleStage = .egg
        self.visualThemeID = visualThemeID
        self.stats = PetStats()
    }
}
