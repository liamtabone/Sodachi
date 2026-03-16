enum PetLifecycleStage: String, Codable, CaseIterable {
    case egg
    case baby
    case child
    case teen
    case adult
    case senior
    case dead

    var displayName: String {
        rawValue.capitalized
    }

    var isAlive: Bool {
        self != .dead
    }
}
