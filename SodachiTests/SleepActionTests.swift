import XCTest
import SwiftData
@testable import Sodachi

final class SleepActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    let action = SleepAction()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Put to sleep

    func testPutToSleepSetsSleepingFlag() {
        let pet = makePet()
        action.putToSleep(pet: pet)
        XCTAssertTrue(pet.isSleeping)
    }

    func testPutToSleepIsIdempotent() {
        let pet = makePet()
        action.putToSleep(pet: pet)
        action.putToSleep(pet: pet)
        XCTAssertTrue(pet.isSleeping)
    }

    func testEggCannotSleep() {
        let pet = makePet()
        // Pet defaults to .egg
        let eggPet = Pet(name: "Egg")
        context.insert(eggPet)
        action.putToSleep(pet: eggPet)
        XCTAssertFalse(eggPet.isSleeping)
    }

    func testDeadPetCannotSleep() {
        let pet = makePet()
        pet.lifecycleStage = .dead
        action.putToSleep(pet: pet)
        XCTAssertFalse(pet.isSleeping)
    }

    // MARK: - Wake up

    func testWakeUpClearsSleepingFlag() {
        let pet = makePet()
        action.putToSleep(pet: pet)
        action.wakeUp(pet: pet)
        XCTAssertFalse(pet.isSleeping)
    }

    func testWakeUpOnAwakePetIsNoOp() {
        let pet = makePet()
        action.wakeUp(pet: pet)
        XCTAssertFalse(pet.isSleeping)
    }

    // MARK: - Energy recovery during decay

    func testEnergyRecoversDuringSleep() {
        let pet = makePet()
        pet.stats?.energy = 20
        action.putToSleep(pet: pet)
        let past = Date.now.addingTimeInterval(-3_600)
        pet.lastUpdatedAt = past
        DecayEngine().process(pet: pet)
        XCTAssertGreaterThan(pet.stats!.energy, 20)
    }

    func testEnergyDecaysWhenAwake() {
        let pet = makePet()
        pet.stats?.energy = 80
        let past = Date.now.addingTimeInterval(-3_600)
        pet.lastUpdatedAt = past
        DecayEngine().process(pet: pet)
        XCTAssertLessThan(pet.stats!.energy, 80)
    }

    func testEnergyCapAt100DuringSleep() {
        let pet = makePet()
        pet.stats?.energy = 99
        action.putToSleep(pet: pet)
        let past = Date.now.addingTimeInterval(-3_600)
        pet.lastUpdatedAt = past
        DecayEngine().process(pet: pet)
        XCTAssertEqual(pet.stats!.energy, 100)
    }

    // MARK: - Visual state

    func testSleepingPetHasSleepingVisualState() {
        let pet = makePet()
        action.putToSleep(pet: pet)
        XCTAssertEqual(pet.visualState, .sleeping)
    }

    func testAwakePetDoesNotHaveSleepingVisualState() {
        let pet = makePet()
        XCTAssertNotEqual(pet.visualState, .sleeping)
    }

    // MARK: - Helpers

    private func makePet() -> Pet {
        let pet = Pet(name: "Taro")
        pet.lifecycleStage = .baby
        context.insert(pet)
        return pet
    }
}
