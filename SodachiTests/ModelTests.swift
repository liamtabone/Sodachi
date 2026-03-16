import XCTest
import SwiftData
@testable import Sodachi

final class ModelTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Pet.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Pet creation

    func testPetDefaultsOnInit() {
        let pet = Pet(name: "Blobby")
        XCTAssertEqual(pet.name, "Blobby")
        XCTAssertEqual(pet.species, "default")
        XCTAssertEqual(pet.visualThemeID, "static")
        XCTAssertEqual(pet.lifecycleStage, .egg)
        XCTAssertNotNil(pet.stats)
    }

    func testPetStatsDefaultsOnInit() {
        let stats = PetStats()
        XCTAssertEqual(stats.hunger, 80)
        XCTAssertEqual(stats.happiness, 80)
        XCTAssertEqual(stats.health, 100)
        XCTAssertEqual(stats.energy, 100)
        XCTAssertEqual(stats.age, 0)
        XCTAssertEqual(stats.weight, 50)
    }

    // MARK: - SwiftData persistence

    func testPetCanBeInsertedAndFetched() throws {
        let pet = Pet(name: "Kochi")
        context.insert(pet)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Pet>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Kochi")
    }

    func testMultiplePetsCanBeInserted() throws {
        context.insert(Pet(name: "Alpha"))
        context.insert(Pet(name: "Beta"))
        context.insert(Pet(name: "Gamma"))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Pet>())
        XCTAssertEqual(fetched.count, 3)
    }

    func testDeletingPetCascadesToStats() throws {
        let pet = Pet(name: "Doomed")
        context.insert(pet)
        try context.save()

        context.delete(pet)
        try context.save()

        let pets = try context.fetch(FetchDescriptor<Pet>())
        let stats = try context.fetch(FetchDescriptor<PetStats>())
        XCTAssertTrue(pets.isEmpty)
        XCTAssertTrue(stats.isEmpty, "Cascade delete should remove orphaned PetStats")
    }

    func testPetStatsCanBeMutated() throws {
        let pet = Pet(name: "Munchy")
        context.insert(pet)
        try context.save()

        pet.stats?.hunger = 30
        pet.stats?.weight = 65
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Pet>()).first
        XCTAssertEqual(fetched?.stats?.hunger, 30)
        XCTAssertEqual(fetched?.stats?.weight, 65)
    }

    // MARK: - Lifecycle stage

    func testLifecycleStageIsAlive() {
        XCTAssertTrue(PetLifecycleStage.egg.isAlive)
        XCTAssertTrue(PetLifecycleStage.adult.isAlive)
        XCTAssertFalse(PetLifecycleStage.dead.isAlive)
    }

    func testLifecycleStageCaseIterable() {
        XCTAssertEqual(PetLifecycleStage.allCases.count, 7)
        XCTAssertEqual(PetLifecycleStage.allCases.first, .egg)
        XCTAssertEqual(PetLifecycleStage.allCases.last, .dead)
    }
}
