import SwiftUI

struct ContentView: View {
    var body: some View {
        PetListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Pet.self, inMemory: true)
}
