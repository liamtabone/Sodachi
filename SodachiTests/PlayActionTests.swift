import XCTest
import SwiftData
@testable import Sodachi

final class PlayActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    let action = PlayAction()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Win / loss

    func testWinIncreasesHappiness() {
        let pet = makePet(happiness: 50)
        action.play(pet: pet, result: MiniGameResult(won: true, happinessChange: 15))
        XCTAssertEqual(pet.stats?.happiness, 65)
    }

    func testLossDecreasesHappiness() {
        let pet = makePet(happiness: 50)
        action.play(pet: pet, result: MiniGameResult(won: false, happinessChange: -5))
        XCTAssertEqual(pet.stats?.happiness, 45)
    }

    func testHappinessCapsAt100() {
        let pet = makePet(happiness: 95)
        action.play(pet: pet, result: MiniGameResult(won: true, happinessChange: 15))
        XCTAssertEqual(pet.stats?.happiness, 100)
    }

    func testHappinessFloorsAt0() {
        let pet = makePet(happiness: 3)
        action.play(pet: pet, result: MiniGameResult(won: false, happinessChange: -10))
        XCTAssertEqual(pet.stats?.happiness, 0)
    }

    // MARK: - Guards

    func testEggIsNotAffected() {
        let pet = makePet(happiness: 50, stage: .egg)
        action.play(pet: pet, result: MiniGameResult(won: true, happinessChange: 15))
        XCTAssertEqual(pet.stats?.happiness, 50)
    }

    func testDeadPetIsNotAffected() {
        let pet = makePet(happiness: 50)
        pet.lifecycleStage = .dead
        action.play(pet: pet, result: MiniGameResult(won: true, happinessChange: 15))
        XCTAssertEqual(pet.stats?.happiness, 50)
    }

    func testSleepingPetIsNotAffected() {
        let pet = makePet(happiness: 50)
        pet.isSleeping = true
        action.play(pet: pet, result: MiniGameResult(won: true, happinessChange: 15))
        XCTAssertEqual(pet.stats?.happiness, 50)
    }

    // MARK: - StubMiniGame

    func testStubMiniGameReturnsWin() {
        var game = StubMiniGame(happinessChange: 20)
        var result: MiniGameResult?
        game.start { result = $0 }
        XCTAssertEqual(result?.won, true)
        XCTAssertEqual(result?.happinessChange, 20)
    }

    // MARK: - Helpers

    private func makePet(happiness: Double = 50, stage: PetLifecycleStage = .baby) -> Pet {
        let pet = Pet(name: "Taro")
        pet.lifecycleStage = stage
        pet.stats?.happiness = happiness
        context.insert(pet)
        return pet
    }
}
