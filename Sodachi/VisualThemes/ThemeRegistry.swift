import SwiftUI

/// Central registry of all available visual themes.
/// Add new theme instances here when implementing additional themes (e.g. PixelSpriteTheme).
struct ThemeRegistry {
    static let available: [any PetVisualTheme] = [
        StaticImageTheme(),
    ]

    /// Returns the theme matching `id`, falling back to `StaticImageTheme` if not found.
    static func theme(for id: String) -> any PetVisualTheme {
        available.first { $0.themeID == id } ?? StaticImageTheme()
    }
}
