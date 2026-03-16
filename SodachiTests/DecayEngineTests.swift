import XCTest
import SwiftData
@testable import Sodachi

final class DecayEngineTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private let engine = DecayEngine()

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Pet.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Helpers

    private func makePet(lastUpdatedAt: Date = .now, stage: PetLifecycleStage = .baby) -> Pet {
        let pet = Pet(name: "Test")
        pet.lastUpdatedAt = lastUpdatedAt
        pet.lifecycleStage = stage
        context.insert(pet)
        return pet
    }

    private func date(hoursAgo hours: Double) -> Date {
        Date.now.addingTimeInterval(-hours * 3_600)
    }

    // MARK: - Primary decay

    func testHungerDecaysOverTime() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2))
        let before = pet.stats!.hunger
        engine.process(pet: pet)
        let expected = before - DecayRates.hungerPerHour * 2
        XCTAssertEqual(pet.stats!.hunger, expected, accuracy: 0.01)
    }

    func testHappinessDecaysOverTime() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2))
        let before = pet.stats!.happiness
        engine.process(pet: pet)
        let expected = before - DecayRates.happinessPerHour * 2
        XCTAssertEqual(pet.stats!.happiness, expected, accuracy: 0.01)
    }

    func testEnergyDecaysOverTime() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2))
        let before = pet.stats!.energy
        engine.process(pet: pet)
        let expected = before - DecayRates.energyPerHour * 2
        XCTAssertEqual(pet.stats!.energy, expected, accuracy: 0.01)
    }

    func testAgeIncreasesOverTime() {
        let elapsed: Double = 7_200 // 2 hours in seconds
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2))
        engine.process(pet: pet)
        XCTAssertEqual(pet.stats!.age, elapsed, accuracy: 1.0)
    }

    // MARK: - Stats floor at 0

    func testStatsDoNotGoBelowZero() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 1000))
        engine.process(pet: pet)
        XCTAssertGreaterThanOrEqual(pet.stats!.hunger, 0)
        XCTAssertGreaterThanOrEqual(pet.stats!.happiness, 0)
        XCTAssertGreaterThanOrEqual(pet.stats!.energy, 0)
        XCTAssertGreaterThanOrEqual(pet.stats!.health, 0)
    }

    // MARK: - Secondary health decay

    func testHealthDecaysWhenHungerIsCritical() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2))
        pet.stats!.hunger = DecayRates.criticalHungerThreshold - 1
        pet.stats!.happiness = 80 // healthy happiness so only hunger triggers
        let healthBefore = pet.stats!.health

        // Stub the hunger so it stays critical (already set before process)
        // We need to process with a very short interval to isolate health decay
        let shortAgo = Date.now.addingTimeInterval(-3_600) // 1 hour
        pet.lastUpdatedAt = shortAgo
        engine.process(pet: pet)

        XCTAssertLessThan(pet.stats!.health, healthBefore)
    }

    func testHealthDecaysWhenHappinessIsCritical() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 1))
        pet.stats!.hunger = 80 // healthy hunger
        pet.stats!.happiness = DecayRates.criticalHappinessThreshold - 1
        let healthBefore = pet.stats!.health
        engine.process(pet: pet)
        XCTAssertLessThan(pet.stats!.health, healthBefore)
    }

    func testHealthDoesNotDecayWhenStatsAreHealthy() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 1))
        pet.stats!.hunger = 80
        pet.stats!.happiness = 80
        let healthBefore = pet.stats!.health
        engine.process(pet: pet)
        XCTAssertEqual(pet.stats!.health, healthBefore, accuracy: 0.01)
    }

    // MARK: - Death

    func testPetDiesWhenHealthReachesZero() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 1000))
        engine.process(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .dead)
    }

    func testDeadPetIsSkipped() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2))
        pet.lifecycleStage = .dead
        let hungerBefore = pet.stats!.hunger
        engine.process(pet: pet)
        XCTAssertEqual(pet.stats!.hunger, hungerBefore, "Dead pet stats should not change")
    }

    func testEggPetIsSkipped() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2), stage: .egg)
        let hungerBefore = pet.stats!.hunger
        let healthBefore = pet.stats!.health
        engine.process(pet: pet)
        XCTAssertEqual(pet.stats!.hunger, hungerBefore, "Egg pet hunger should not decay")
        XCTAssertEqual(pet.stats!.health, healthBefore, "Egg pet health should not decay")
    }

    func testNonEggPetDoesDecay() {
        let pet = makePet(lastUpdatedAt: date(hoursAgo: 2), stage: .baby)
        let hungerBefore = pet.stats!.hunger
        engine.process(pet: pet)
        XCTAssertLessThan(pet.stats!.hunger, hungerBefore, "Baby pet hunger should decay")
    }

    // MARK: - Timestamp

    func testLastUpdatedAtIsRefreshedAfterProcessing() {
        let past = date(hoursAgo: 5)
        let pet = makePet(lastUpdatedAt: past)
        let before = Date.now
        engine.process(pet: pet)
        XCTAssertGreaterThanOrEqual(pet.lastUpdatedAt, before)
    }

    func testNoDecayWhenElapsedIsZero() {
        let pet = makePet(lastUpdatedAt: .now)
        let hungerBefore = pet.stats!.hunger
        engine.process(pet: pet, now: .now)
        XCTAssertEqual(pet.stats!.hunger, hungerBefore)
    }

    // MARK: - Multiple pets

    func testProcessAllHandlesMultiplePets() {
        let pets = (0..<3).map { i -> Pet in
            let pet = Pet(name: "Pet\(i)")
            pet.lastUpdatedAt = date(hoursAgo: 2)
            context.insert(pet)
            return pet
        }
        let before = pets.map { $0.stats!.hunger }
        engine.processAll(pets: pets)
        for (pet, originalHunger) in zip(pets, before) {
            XCTAssertLessThan(pet.stats!.hunger, originalHunger)
        }
    }
}
