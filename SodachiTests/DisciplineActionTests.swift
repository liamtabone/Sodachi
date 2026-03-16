import XCTest
import SwiftData
@testable import Sodachi

final class DisciplineActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    let action = DisciplineAction()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - When misbehaving

    func testDisciplineIncreasesDisciplineMeter() {
        let pet = makePet(discipline: 50)
        pet.isMisbehaving = true
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.discipline, 65)
    }

    func testDisciplineClearsMisbehavingFlag() {
        let pet = makePet()
        pet.isMisbehaving = true
        action.discipline(pet: pet)
        XCTAssertFalse(pet.isMisbehaving)
    }

    func testDisciplineMeterCapsAt100() {
        let pet = makePet(discipline: 95)
        pet.isMisbehaving = true
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.discipline, 100)
    }

    func testMisbehavingDisciplineDoesNotAffectHappiness() {
        let pet = makePet(happiness: 80)
        pet.isMisbehaving = true
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.happiness, 80)
    }

    // MARK: - When not misbehaving

    func testUnnecessaryDisciplinePenalisesHappiness() {
        let pet = makePet(happiness: 80)
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.happiness, 65)
    }

    func testUnnecessaryDisciplineDoesNotChangeDisciplineMeter() {
        let pet = makePet(discipline: 50)
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.discipline, 50)
    }

    func testHappinessFloorsAt0() {
        let pet = makePet(happiness: 10)
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.happiness, 0)
    }

    // MARK: - Guards

    func testEggIsNotDisciplined() {
        let pet = Pet(name: "Egg")
        pet.stats?.discipline = 50
        context.insert(pet)
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.discipline, 50)
    }

    func testSleepingPetIsNotDisciplined() {
        let pet = makePet(happiness: 80)
        pet.isSleeping = true
        action.discipline(pet: pet)
        XCTAssertEqual(pet.stats?.happiness, 80)
    }

    // MARK: - Helpers

    private func makePet(happiness: Double = 80, discipline: Double = 50) -> Pet {
        let pet = Pet(name: "Taro")
        pet.lifecycleStage = .baby
        pet.stats?.happiness = happiness
        pet.stats?.discipline = discipline
        context.insert(pet)
        return pet
    }
}
