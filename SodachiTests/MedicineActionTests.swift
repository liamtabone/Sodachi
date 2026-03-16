import XCTest
import SwiftData
@testable import Sodachi

final class MedicineActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    let action = MedicineAction()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Health restore

    func testMedicineRestoresHealth() {
        let pet = makePet(health: 40)
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.health, 70)
    }

    func testHealthCapsAt100() {
        let pet = makePet(health: 90)
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.health, 100)
    }

    // MARK: - Happiness penalty when healthy

    func testUnnecessaryMedicinePenalisesHappiness() {
        let pet = makePet(health: MedicineAction.healthyThreshold, happiness: 80)
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.happiness, 70)
    }

    func testNecessaryMedicineDoesNotPenaliseHappiness() {
        let pet = makePet(health: MedicineAction.healthyThreshold - 1, happiness: 80)
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.happiness, 80)
    }

    func testHappinessFloorsAt0OnPenalty() {
        let pet = makePet(health: 100, happiness: 5)
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.happiness, 0)
    }

    // MARK: - Guards

    func testEggIsNotTreated() {
        let pet = Pet(name: "Egg")
        pet.stats?.health = 50
        context.insert(pet)
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.health, 50)
    }

    func testDeadPetIsNotTreated() {
        let pet = makePet(health: 50)
        pet.lifecycleStage = .dead
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.health, 50)
    }

    func testSleepingPetIsNotTreated() {
        let pet = makePet(health: 50)
        pet.isSleeping = true
        action.administer(pet: pet)
        XCTAssertEqual(pet.stats?.health, 50)
    }

    // MARK: - Helpers

    private func makePet(health: Double = 50, happiness: Double = 80) -> Pet {
        let pet = Pet(name: "Taro")
        pet.lifecycleStage = .baby
        pet.stats?.health = health
        pet.stats?.happiness = happiness
        context.insert(pet)
        return pet
    }
}
