import XCTest
import SwiftData
@testable import Sodachi

final class GameScreenTests: XCTestCase {
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

    // MARK: - visualState

    func testHealthyPetIsIdle() {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        // Default stats: health = 100
        XCTAssertEqual(pet.visualState, .idle)
    }

    func testLowHealthPetIsSick() {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        pet.stats?.health = 29
        XCTAssertEqual(pet.visualState, .sick)
    }

    func testHealthBoundary_30IsNotSick() {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        pet.stats?.health = 30
        XCTAssertEqual(pet.visualState, .idle)
    }

    func testDeadPetVisualStateIsDead() {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        pet.lifecycleStage = .dead
        XCTAssertEqual(pet.visualState, .dead)
    }

    func testPetWithNoStatsIsDead() {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        pet.stats = nil
        XCTAssertEqual(pet.visualState, .dead)
    }
}
