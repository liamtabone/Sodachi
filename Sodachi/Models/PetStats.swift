import SwiftData
import Foundation

@Model
final class PetStats {
    /// 0–100. Decreases over time; pet grows hungrier.
    var hunger: Double
    /// 0–100. Decreases over time; requires play and attention.
    var happiness: Double
    /// 0–100. Decreases when hunger or hygiene is neglected. Reaches 0 = death.
    var health: Double
    /// 0–100. Decreases over time; restored by sleep.
    var energy: Double
    /// Time elapsed since the pet was born, in seconds.
    var age: TimeInterval
    /// Arbitrary weight units. Increases with feeding, especially snacks.
    var weight: Double
    /// 0–100. Increases over time; reaching 100 causes an accident.
    var toiletNeed: Double
    /// 0–100. Obedience meter; increases when disciplined appropriately.
    var discipline: Double

    init(
        hunger: Double = 80,
        happiness: Double = 80,
        health: Double = 100,
        energy: Double = 100,
        age: TimeInterval = 0,
        weight: Double = 50,
        toiletNeed: Double = 0,
        discipline: Double = 50
    ) {
        self.hunger = hunger
        self.happiness = happiness
        self.health = health
        self.energy = energy
        self.age = age
        self.weight = weight
        self.toiletNeed = toiletNeed
        self.discipline = discipline
    }
}
