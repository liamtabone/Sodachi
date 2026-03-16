import SwiftUI

/// A single animation clip: one or more frames played at a fixed rate.
/// A static image is represented as a single-frame animation.
///
/// > Note: This struct covers frame-array animations with a uniform frame duration.
/// > It does not support sprite sheets, per-frame metadata, variable frame timing,
/// > or theme-controlled playback (e.g. ping-pong, ease curves). If those are needed
/// > in the future this type — and the `PetVisualTheme` protocol — will need to change.
struct PetAnimation {
    /// Ordered animation frames. Always contains at least one image.
    let frames: [Image]
    /// Duration of each frame in seconds. Ignored when `frames` has only one element.
    let frameDuration: TimeInterval
}

/// Defines a visual skin for a pet.
/// Concrete implementations supply an animation for every combination of
/// lifecycle stage and visual state.
protocol PetVisualTheme {
    /// Display name shown in the theme picker.
    var name: String { get }

    /// Returns the animation to display for the given lifecycle stage and visual state.
    func animation(for stage: PetLifecycleStage, state: PetVisualState) -> PetAnimation
}
