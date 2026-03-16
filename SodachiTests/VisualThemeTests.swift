import XCTest
import SwiftUI
@testable import Sodachi

final class VisualThemeTests: XCTestCase {

    // MARK: - PetVisualState

    func testAllVisualStatesExist() {
        let states: [PetVisualState] = [.idle, .eating, .playing, .sleeping, .sick, .dead]
        XCTAssertEqual(states.count, 6)
    }

    // MARK: - PetAnimation

    func testPetAnimationStoresFramesAndDuration() {
        let image = Image(systemName: "circle")
        let animation = PetAnimation(frames: [image, image], frameDuration: 0.2)
        XCTAssertEqual(animation.frames.count, 2)
        XCTAssertEqual(animation.frameDuration, 0.2)
    }

    // MARK: - PetVisualTheme conformance

    func testConcreteThemeConformsToProtocol() {
        let theme: any PetVisualTheme = StubTheme()
        XCTAssertFalse(theme.name.isEmpty)
        // animation(for:state:) must return at least one frame for every combination.
        for stage in allStages() {
            for state in allStates() {
                let animation = theme.animation(for: stage, state: state)
                XCTAssertFalse(animation.frames.isEmpty, "Expected at least one frame for \(stage)/\(state)")
            }
        }
    }

    func testThemeNameIsNonEmpty() {
        XCTAssertFalse(StubTheme().name.isEmpty)
    }

    // MARK: - StaticImageTheme

    func testStaticImageThemeID() {
        XCTAssertEqual(StaticImageTheme.themeID, "static")
    }

    func testStaticImageThemeReturnsOneFramePerCombination() {
        let theme = StaticImageTheme()
        for stage in allStages() {
            for state in allStates() {
                let animation = theme.animation(for: stage, state: state)
                XCTAssertEqual(animation.frames.count, 1, "Expected exactly one frame for \(stage)/\(state)")
                XCTAssertEqual(animation.frameDuration, 0)
            }
        }
    }

    func testStaticImageThemeNameIsNonEmpty() {
        XCTAssertFalse(StaticImageTheme().name.isEmpty)
    }

    // MARK: - Helpers

    private func allStages() -> [PetLifecycleStage] {
        [.egg, .baby, .child, .teen, .adult, .senior, .dead]
    }

    private func allStates() -> [PetVisualState] {
        [.idle, .eating, .playing, .sleeping, .sick, .dead]
    }
}

// MARK: - Test double

/// Minimal `PetVisualTheme` conformance used only in tests.
private struct StubTheme: PetVisualTheme {
    var name: String { "Stub" }
    func animation(for stage: PetLifecycleStage, state: PetVisualState) -> PetAnimation {
        PetAnimation(frames: [Image(systemName: "circle")], frameDuration: 0)
    }
}
