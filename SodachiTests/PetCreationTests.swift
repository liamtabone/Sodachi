import XCTest
import SwiftData
@testable import Sodachi

final class PetCreationTests: XCTestCase {
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

    // MARK: - ThemeRegistry

    func testThemeRegistryHasAtLeastOneTheme() {
        XCTAssertFalse(ThemeRegistry.available.isEmpty)
    }

    func testThemeRegistryResolvesStaticTheme() {
        let theme = ThemeRegistry.theme(for: StaticImageTheme.themeID)
        XCTAssertEqual(theme.themeID, StaticImageTheme.themeID)
    }

    func testThemeRegistryFallsBackForUnknownID() {
        let theme = ThemeRegistry.theme(for: "unknown-theme-id")
        XCTAssertEqual(theme.themeID, StaticImageTheme.themeID)
    }

    // MARK: - Pet creation

    func testCreatedPetHasCorrectName() throws {
        let pet = Pet(name: "Taro", visualThemeID: StaticImageTheme.themeID)
        context.insert(pet)
        let fetched = try context.fetch(FetchDescriptor<Pet>())
        XCTAssertEqual(fetched.first?.name, "Taro")
    }

    func testCreatedPetHasCorrectThemeID() throws {
        let pet = Pet(name: "Taro", visualThemeID: StaticImageTheme.themeID)
        context.insert(pet)
        XCTAssertEqual(pet.visualThemeID, StaticImageTheme.themeID)
    }

    func testCreatedPetDefaultsToEggStage() throws {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        XCTAssertEqual(pet.lifecycleStage, .egg)
    }

    func testCreatedPetHasStats() throws {
        let pet = Pet(name: "Taro")
        context.insert(pet)
        XCTAssertNotNil(pet.stats)
    }

    func testThemeIDPersistedOnPet() throws {
        let pet = Pet(name: "Taro", visualThemeID: "static")
        context.insert(pet)
        try context.save()
        let fetched = try context.fetch(FetchDescriptor<Pet>())
        XCTAssertEqual(fetched.first?.visualThemeID, "static")
    }
}
