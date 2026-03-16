struct SpeciesRegistry {
    static let available: [any PetSpecies] = [DogSpecies(), CatSpecies()]

    /// Resolves a species ID to a concrete species. Falls back to `DogSpecies` if unknown.
    static func species(for id: String) -> any PetSpecies {
        available.first { $0.speciesID == id } ?? DogSpecies()
    }
}
