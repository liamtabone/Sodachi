import SwiftUI

/// A visual theme that displays a single static image per lifecycle stage.
/// Visual state does not affect the image — this theme has no animations.
///
/// Images are loaded from `Assets.xcassets/Themes/static/` and named by
/// lifecycle stage (e.g. `egg`, `baby`). Empty imagesets are included as
/// placeholders; replace them with real art to update the theme.
///
/// `themeID` matches the default value of `Pet.visualThemeID` so new pets
/// use this theme automatically.
struct StaticImageTheme: PetVisualTheme {
    static let themeID = "static"

    var themeID: String { StaticImageTheme.themeID }
    var name: String { "Static" }

    func animation(for stage: PetLifecycleStage, state: PetVisualState) -> PetAnimation {
        PetAnimation(frames: [Image("Themes/static/\(stage.rawValue)")], frameDuration: 0)
    }
}
