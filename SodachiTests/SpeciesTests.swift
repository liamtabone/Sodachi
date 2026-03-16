import XCTest
import SwiftData
@testable import Sodachi

final class SpeciesTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private let decayEngine = DecayEngine()
    private let lifecycleEngine = LifecycleEngine()

    override func setUpWithError() throws {
        container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Registry

    func testRegistryResolvesKnownSpecies() {
        let dog = SpeciesRegistry.species(for: DogSpecies.speciesID)
        XCTAssertEqual(dog.speciesID, DogSpecies.speciesID)
        let cat = SpeciesRegistry.species(for: CatSpecies.speciesID)
        XCTAssertEqual(cat.speciesID, CatSpecies.speciesID)
    }

    func testRegistryFallsBackToDogForUnknownID() {
        let unknown = SpeciesRegistry.species(for: "unknown_xyz")
        XCTAssertEqual(unknown.speciesID, DogSpecies.speciesID)
    }

    // MARK: - Starting stats

    func testDogPetSeededWithDogStartingStats() {
        let pet = makePet(species: DogSpecies.speciesID)
        let expected = DogSpecies().startingStats
        XCTAssertEqual(pet.stats?.hunger, expected.hunger)
        XCTAssertEqual(pet.stats?.happiness, expected.happiness)
        XCTAssertEqual(pet.stats?.weight, expected.weight)
    }

    func testCatPetSeededWithCatStartingStats() {
        let pet = makePet(species: CatSpecies.speciesID)
        let expected = CatSpecies().startingStats
        XCTAssertEqual(pet.stats?.hunger, expected.hunger)
        XCTAssertEqual(pet.stats?.happiness, expected.happiness)
        XCTAssertEqual(pet.stats?.weight, expected.weight)
    }

    // MARK: - Per-species decay

    func testDogHungerDecaysFasterThanCat() {
        let dog = makePet(species: DogSpecies.speciesID)
        let cat = makePet(species: CatSpecies.speciesID)
        // Give both the same starting hunger and advance time
        dog.stats?.hunger = 80
        cat.stats?.hunger = 80
        let past = Date.now.addingTimeInterval(-3_600) // 1 hour ago
        dog.lastUpdatedAt = past
        cat.lastUpdatedAt = past

        decayEngine.process(pet: dog)
        decayEngine.process(pet: cat)

        XCTAssertLessThan(dog.stats!.hunger, cat.stats!.hunger,
            "Dog should lose hunger faster than cat")
    }

    func testCatHappinessDecaysSlowerThanDog() {
        let dog = makePet(species: DogSpecies.speciesID)
        let cat = makePet(species: CatSpecies.speciesID)
        dog.stats?.happiness = 80
        cat.stats?.happiness = 80
        let past = Date.now.addingTimeInterval(-3_600)
        dog.lastUpdatedAt = past
        cat.lastUpdatedAt = past

        decayEngine.process(pet: dog)
        decayEngine.process(pet: cat)

        XCTAssertLessThan(dog.stats!.happiness, cat.stats!.happiness,
            "Cat happiness should decay slower than dog")
    }

    // MARK: - Per-species lifecycle

    func testDogReachesBabyBeforeCatAtSameAge() {
        // Both species share the same baby threshold (15 min), so test differentiation
        // at the child threshold instead — dog reaches child faster than cat
        let dogBaby = DogSpecies().lifecycleThresholds.baby
        let catBaby = CatSpecies().lifecycleThresholds.baby
        let dogChild = DogSpecies().lifecycleThresholds.child
        let catChild = CatSpecies().lifecycleThresholds.child

        let dog = makePet(species: DogSpecies.speciesID)
        let cat = makePet(species: CatSpecies.speciesID)

        // Set both to an age between dogChild and catChild (dog becomes child, cat stays baby)
        let testAge = (dogChild + catChild) / 2
        dog.stats?.age = testAge
        cat.stats?.age = testAge
        dog.lifecycleStage = .baby
        cat.lifecycleStage = .baby

        lifecycleEngine.evaluate(pet: dog)
        lifecycleEngine.evaluate(pet: cat)

        XCTAssertEqual(dog.lifecycleStage, .child, "Dog should advance to child at this age")
        XCTAssertEqual(cat.lifecycleStage, .baby, "Cat should still be baby at this age")

        _ = dogBaby
        _ = catBaby
    }
}

// MARK: - Helpers

private extension SpeciesTests {
    func makePet(species: String) -> Pet {
        let pet = Pet(name: "Test", species: species)
        pet.lifecycleStage = .baby
        context.insert(pet)
        return pet
    }
}
