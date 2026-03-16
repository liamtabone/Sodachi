import XCTest
import SwiftData
@testable import Sodachi

final class LifecycleEngineTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private let engine = LifecycleEngine()

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Pet.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Helpers

    private func makePet(age: TimeInterval) -> Pet {
        let pet = Pet(name: "Test")
        pet.stats!.age = age
        context.insert(pet)
        return pet
    }

    // MARK: - Stage transitions

    func testStaysEggBelowBabyThreshold() {
        let pet = makePet(age: LifecycleThresholds.baby - 1)
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .egg)
    }

    func testTransitionsToBabyAtThreshold() {
        let pet = makePet(age: LifecycleThresholds.baby)
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .baby)
    }

    func testTransitionsToChildAtThreshold() {
        let pet = makePet(age: LifecycleThresholds.child)
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .child)
    }

    func testTransitionsToTeenAtThreshold() {
        let pet = makePet(age: LifecycleThresholds.teen)
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .teen)
    }

    func testTransitionsToAdultAtThreshold() {
        let pet = makePet(age: LifecycleThresholds.adult)
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .adult)
    }

    func testTransitionsToSeniorAtThreshold() {
        let pet = makePet(age: LifecycleThresholds.senior)
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .senior)
    }

    func testNaturalDeathAtOldAge() {
        let pet = makePet(age: LifecycleThresholds.naturalDeath)
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .dead)
    }

    // MARK: - Stage only advances

    func testStageDoesNotRegress() {
        let pet = makePet(age: LifecycleThresholds.adult)
        pet.lifecycleStage = .senior
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .senior, "Stage should never regress")
    }

    // MARK: - Dead pets skipped

    func testDeadPetIsSkipped() {
        let pet = makePet(age: LifecycleThresholds.baby)
        pet.lifecycleStage = .dead
        engine.evaluate(pet: pet)
        XCTAssertEqual(pet.lifecycleStage, .dead)
    }

    // MARK: - evaluateAll

    func testEvaluateAllTransitionsMultiplePets() {
        let pets = [
            makePet(age: LifecycleThresholds.baby),
            makePet(age: LifecycleThresholds.teen),
            makePet(age: LifecycleThresholds.senior)
        ]
        engine.evaluateAll(pets: pets)
        XCTAssertEqual(pets[0].lifecycleStage, .baby)
        XCTAssertEqual(pets[1].lifecycleStage, .teen)
        XCTAssertEqual(pets[2].lifecycleStage, .senior)
    }

    // MARK: - Integration with DecayEngine

    func testDecayThenLifecycleCorrectlyAgesAPet() {
        let pet = Pet(name: "Aged")
        // Simulate the pet being created 13 hours ago
        pet.lastUpdatedAt = Date.now.addingTimeInterval(-13 * 3_600)
        context.insert(pet)

        DecayEngine().process(pet: pet)
        engine.evaluate(pet: pet)

        // 13 hours > child threshold (12h), so should be child
        XCTAssertEqual(pet.lifecycleStage, .child)
    }
}
