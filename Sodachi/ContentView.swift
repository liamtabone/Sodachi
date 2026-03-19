import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var pets: [Pet]

    var body: some View {
        if let pet = pets.first {
            GameScreenView(pet: pet)
        } else {
            PetCreationView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Pet.self, inMemory: true)
}
