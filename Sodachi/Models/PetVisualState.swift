import Foundation

/// The visual/animation state of a pet, independent of its lifecycle stage.
/// Used by `PetVisualTheme` to select the correct image or animation.
enum PetVisualState {
    case idle
    case eating
    case playing
    case sleeping
    case sick
    case dead
}
