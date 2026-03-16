import XCTest
import SwiftData
@testable import Sodachi

final class PetListTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func testNewPetsAreAlive() throws {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        XCTAssertTrue(pet.lifecycleStage.isAlive)
    }

    func testDeadPetIsNotAlive() throws {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        pet.lifecycleStage = .dead
        XCTAssertFalse(pet.lifecycleStage.isAlive)
    }

    func testAlivePetsFilteredCorrectly() throws {
        let alive = Pet(name: "Alive")
        let dead = Pet(name: "Dead")
        dead.lifecycleStage = .dead
        context.insert(alive)
        context.insert(dead)

        let all = try context.fetch(FetchDescriptor<Pet>())
        let alivePets = all.filter { $0.lifecycleStage.isAlive }
        let deadPets = all.filter { !$0.lifecycleStage.isAlive }

        XCTAssertEqual(alivePets.count, 1)
        XCTAssertEqual(alivePets.first?.name, "Alive")
        XCTAssertEqual(deadPets.count, 1)
        XCTAssertEqual(deadPets.first?.name, "Dead")
    }

    func testMultiplePetsStoredIndependently() throws {
        let names = ["Taro", "Hana", "Kiro"]
        names.forEach { context.insert(Pet(name: $0)) }

        let all = try context.fetch(FetchDescriptor<Pet>())
        XCTAssertEqual(all.count, 3)
        XCTAssertEqual(Set(all.map(\.name)), Set(names))
    }

    func testEmptyListReturnsNoPets() throws {
        let all = try context.fetch(FetchDescriptor<Pet>())
        XCTAssertTrue(all.isEmpty)
    }
}
