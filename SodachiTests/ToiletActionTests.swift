import XCTest
import SwiftData
@testable import Sodachi

final class ToiletActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    let action = ToiletAction()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Use toilet

    func testToiletResetsNeed() {
        let pet = makePet()
        pet.stats?.toiletNeed = 70
        action.use(pet: pet)
        XCTAssertEqual(pet.stats?.toiletNeed, 0)
    }

    func testToiletOnZeroNeedIsNoOp() {
        let pet = makePet()
        action.use(pet: pet)
        XCTAssertEqual(pet.stats?.toiletNeed, 0)
    }

    // MARK: - Guards

    func testEggCannotUseToilet() {
        let pet = Pet(name: "Egg")
        pet.stats?.toiletNeed = 60
        context.insert(pet)
        action.use(pet: pet)
        XCTAssertEqual(pet.stats?.toiletNeed, 60)
    }

    func testSleepingPetCannotUseToilet() {
        let pet = makePet()
        pet.stats?.toiletNeed = 60
        pet.isSleeping = true
        action.use(pet: pet)
        XCTAssertEqual(pet.stats?.toiletNeed, 60)
    }

    // MARK: - Toilet need accumulation (DecayEngine)

    func testToiletNeedAccumulatesOverTime() {
        let pet = makePet()
        pet.stats?.toiletNeed = 0
        let past = Date.now.addingTimeInterval(-1 * 3_600)
        pet.lastUpdatedAt = past
        DecayEngine().process(pet: pet)
        XCTAssertGreaterThan(pet.stats!.toiletNeed, 0)
    }

    func testAccidentOccursWhenNeedReaches100() {
        let pet = makePet()
        pet.stats?.toiletNeed = 95
        let past = Date.now.addingTimeInterval(-1 * 3_600) // enough to push over 100
        pet.lastUpdatedAt = past
        let poopBefore = pet.poopCount
        DecayEngine().process(pet: pet)
        // Need should have reset and poop should have increased
        XCTAssertEqual(pet.stats!.toiletNeed, 0, "Toilet need should reset after accident")
        XCTAssertGreaterThan(pet.poopCount, poopBefore, "An accident should add poop")
    }

    func testAccidentPenalisesHealthAndHappiness() {
        let pet = makePet()
        pet.stats?.toiletNeed = 95
        pet.stats?.health = 80
        pet.stats?.happiness = 80
        let past = Date.now.addingTimeInterval(-1 * 3_600)
        pet.lastUpdatedAt = past
        DecayEngine().process(pet: pet)
        XCTAssertLessThan(pet.stats!.health, 80)
        XCTAssertLessThan(pet.stats!.happiness, 80)
    }

    // MARK: - Helpers

    private func makePet() -> Pet {
        let pet = Pet(name: "Taro")
        pet.lifecycleStage = .baby
        context.insert(pet)
        return pet
    }
}
