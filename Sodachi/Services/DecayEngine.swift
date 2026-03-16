import Foundation
import SwiftData

struct DecayEngine {
    /// Processes stat decay for a single pet based on time elapsed since `lastUpdatedAt`.
    /// Dead pets are skipped. Updates `lastUpdatedAt` to `now` after processing.
    func process(pet: Pet, now: Date = .now) {
        guard pet.lifecycleStage.isAlive, pet.lifecycleStage != .egg, let stats = pet.stats else { return }

        let elapsed = now.timeIntervalSince(pet.lastUpdatedAt)
        guard elapsed > 0 else { return }

        let hours = elapsed / 3_600
        let rates = SpeciesRegistry.species(for: pet.species).decayRates

        // Primary stat decay
        stats.hunger = max(0, stats.hunger - rates.hungerPerHour * hours)
        stats.happiness = max(0, stats.happiness - rates.happinessPerHour * hours)
        if pet.isSleeping {
            stats.energy = min(100, stats.energy + rates.energyRecoveryPerHour * hours)
        } else {
            stats.energy = max(0, stats.energy - rates.energyPerHour * hours)
        }
        stats.age += elapsed

        // Secondary: health drops when hunger is critically low
        if stats.hunger < rates.criticalHungerThreshold {
            stats.health = max(0, stats.health - rates.healthPerHourFromHunger * hours)
        }

        // Secondary: health drops when happiness is critically low
        if stats.happiness < rates.criticalHappinessThreshold {
            stats.health = max(0, stats.health - rates.healthPerHourFromSadness * hours)
        }

        // Poop accumulation
        pet.poopProgress += rates.poopRatePerHour * hours
        let newPoops = Int(pet.poopProgress)
        if newPoops > 0 {
            pet.poopCount += newPoops
            pet.poopProgress -= Double(newPoops)
        }

        // Health degrades from uncleaned poop
        if pet.poopCount > 0 {
            stats.health = max(0, stats.health - rates.healthDecayPerPoopPerHour * Double(pet.poopCount) * hours)
        }

        // Toilet need accumulation; accident at 100
        stats.toiletNeed = min(100, stats.toiletNeed + rates.toiletNeedPerHour * hours)
        if stats.toiletNeed >= 100 {
            stats.toiletNeed = 0
            pet.poopCount += 1
            stats.health    = max(0, stats.health    - 10)
            stats.happiness = max(0, stats.happiness - 10)
        }

        // Death from health depletion
        if stats.health <= 0 {
            pet.lifecycleStage = .dead
        }

        pet.lastUpdatedAt = now
    }

    /// Processes decay for all pets. Typically called once on app launch.
    func processAll(pets: [Pet], now: Date = .now) {
        for pet in pets {
            process(pet: pet, now: now)
        }
    }
}
