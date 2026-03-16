import Foundation

/// Result returned by a mini-game when it completes.
struct MiniGameResult {
    let won: Bool
    /// Happiness delta to apply to the pet (positive or negative).
    let happinessChange: Double
}

/// Contract for all mini-game implementations.
/// Concrete games are out of scope for this issue — see future issues.
///
/// - Note: This protocol intentionally does not carry SwiftUI dependencies.
///   The view layer is responsible for presenting the game UI.
protocol MiniGame {
    var name: String { get }
    /// Called when the player initiates the game. Implementations should
    /// trigger their own UI and eventually call `onComplete`.
    mutating func start(onComplete: @escaping (MiniGameResult) -> Void)
}

/// Stub implementation used for testing the play action hook.
/// Always reports a win with a fixed happiness bonus.
struct StubMiniGame: MiniGame {
    var name: String { "Stub" }
    var happinessChange: Double

    init(happinessChange: Double = 15) {
        self.happinessChange = happinessChange
    }

    mutating func start(onComplete: @escaping (MiniGameResult) -> Void) {
        onComplete(MiniGameResult(won: true, happinessChange: happinessChange))
    }
}
