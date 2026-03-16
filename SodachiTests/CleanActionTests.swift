import XCTest
import SwiftData
@testable import Sodachi

final class CleanActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    let action = CleanAction()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Clean

    func testCleanRemovesAllPoop() {
        let pet = makePet()
        pet.poopCount = 3
        action.clean(pet: pet)
        XCTAssertEqual(pet.poopCount, 0)
    }

    func testCleanOnCleanPetIsNoOp() {
        let pet = makePet()
        action.clean(pet: pet)
        XCTAssertEqual(pet.poopCount, 0)
    }

    // MARK: - Guards

    func testEggIsNotCleaned() {
        let pet = Pet(name: "Egg")
        pet.poopCount = 2
        context.insert(pet)
        action.clean(pet: pet)
        XCTAssertEqual(pet.poopCount, 2)
    }

    func testDeadPetIsNotCleaned() {
        let pet = makePet()
        pet.poopCount = 2
        pet.lifecycleStage = .dead
        action.clean(pet: pet)
        XCTAssertEqual(pet.poopCount, 2)
    }

    func testSleepingPetIsNotCleaned() {
        let pet = makePet()
        pet.poopCount = 2
        pet.isSleeping = true
        action.clean(pet: pet)
        XCTAssertEqual(pet.poopCount, 2)
    }

    // MARK: - Poop accumulation in decay

    func testPoopAccumulatesOverTime() {
        let pet = makePet()
        // Dog rate is 0.33/hr; 4 hours => ~1 poop
        let past = Date.now.addingTimeInterval(-4 * 3_600)
        pet.lastUpdatedAt = past
        DecayEngine().process(pet: pet)
        XCTAssertGreaterThan(pet.poopCount, 0)
    }

    func testHealthDecaysFromPoop() {
        let pet = makePet()
        pet.poopCount = 3
        let past = Date.now.addingTimeInterval(-1 * 3_600)
        pet.lastUpdatedAt = past
        let healthBefore = pet.stats!.health
        DecayEngine().process(pet: pet)
        XCTAssertLessThan(pet.stats!.health, healthBefore)
    }

    // MARK: - Helpers

    private func makePet() -> Pet {
        let pet = Pet(name: "Taro")
        pet.lifecycleStage = .baby
        context.insert(pet)
        return pet
    }
}
