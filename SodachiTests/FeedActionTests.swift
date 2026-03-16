import XCTest
import SwiftData
@testable import Sodachi

final class FeedActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    let action = FeedAction()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Meal

    func testMealRestoresHunger() {
        let pet = makePet(hunger: 40)
        action.feed(pet: pet, foodType: .meal)
        XCTAssertEqual(pet.stats?.hunger, 70)
    }

    func testMealIncreasesWeightModerately() {
        let pet = makePet()
        let before = pet.stats?.weight ?? 0
        action.feed(pet: pet, foodType: .meal)
        XCTAssertEqual(pet.stats?.weight, before + 1.0)
    }

    func testMealDoesNotAffectHappiness() {
        let pet = makePet(happiness: 60)
        action.feed(pet: pet, foodType: .meal)
        XCTAssertEqual(pet.stats?.happiness, 60)
    }

    // MARK: - Snack

    func testSnackRestoresHungerSlightly() {
        let pet = makePet(hunger: 40)
        action.feed(pet: pet, foodType: .snack)
        XCTAssertEqual(pet.stats?.hunger, 50)
    }

    func testSnackBoostsHappiness() {
        let pet = makePet(happiness: 60)
        action.feed(pet: pet, foodType: .snack)
        XCTAssertEqual(pet.stats?.happiness, 70)
    }

    func testSnackIncreasesWeightMoreThanMeal() {
        let pet = makePet()
        let before = pet.stats?.weight ?? 0
        action.feed(pet: pet, foodType: .snack)
        XCTAssertEqual(pet.stats?.weight, before + 2.0)
    }

    // MARK: - Caps

    func testHungerCapsAt100() {
        let pet = makePet(hunger: 90)
        action.feed(pet: pet, foodType: .meal)
        XCTAssertEqual(pet.stats?.hunger, 100)
    }

    func testHappinessCapsAt100() {
        let pet = makePet(happiness: 95)
        action.feed(pet: pet, foodType: .snack)
        XCTAssertEqual(pet.stats?.happiness, 100)
    }

    // MARK: - Feeding when not hungry

    func testWeightIncreasesEvenWhenFull() {
        let pet = makePet(hunger: 100)
        let before = pet.stats?.weight ?? 0
        action.feed(pet: pet, foodType: .meal)
        XCTAssertGreaterThan(pet.stats?.weight ?? 0, before)
    }

    // MARK: - Dead / no stats

    func testDeadPetIsNotFed() {
        let pet = makePet(hunger: 40)
        pet.lifecycleStage = .dead
        action.feed(pet: pet, foodType: .meal)
        XCTAssertEqual(pet.stats?.hunger, 40)
    }

    func testEggPetIsNotFed() {
        let pet = makePet(hunger: 40, stage: .egg)
        action.feed(pet: pet, foodType: .meal)
        XCTAssertEqual(pet.stats?.hunger, 40, "Egg pet should not be fed")
    }

    func testLastUpdatedAtIsRefreshed() {
        let pet = makePet()
        let before = pet.lastUpdatedAt
        action.feed(pet: pet, foodType: .meal)
        XCTAssertGreaterThanOrEqual(pet.lastUpdatedAt, before)
    }

    // MARK: - Helpers

    private func makePet(hunger: Double = 50, happiness: Double = 80, stage: PetLifecycleStage = .baby) -> Pet {
        let pet = Pet(name: "Taro")
        pet.lifecycleStage = stage
        pet.stats?.hunger = hunger
        pet.stats?.happiness = happiness
        context.insert(pet)
        return pet
    }
}
