import SwiftUI
import SwiftData

struct PetListView: View {
    @Query(sort: \Pet.createdAt) private var pets: [Pet]
    @Environment(\.modelContext) private var context
    @State private var showingNewPetSheet = false
    @State private var navigateToPet: Pet?

    private var alivePets: [Pet] { pets.filter { $0.lifecycleStage.isAlive } }
    private var deadPets: [Pet] { pets.filter { !$0.lifecycleStage.isAlive } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(alivePets) { pet in
                        NavigationLink(destination: GameScreenView(pet: pet)) {
                            PetRowView(pet: pet)
                        }
                    }
                }

                if !deadPets.isEmpty {
                    Section("Deceased") {
                        ForEach(deadPets) { pet in
                            PetRowView(pet: pet)
                                .opacity(0.5)
                        }
                    }
                }
            }
            .navigationTitle("My Pets")
            .navigationDestination(item: $navigateToPet) { pet in
                GameScreenView(pet: pet)
            }
            .overlay {
                if pets.isEmpty {
                    ContentUnavailableView(
                        "No Pets Yet",
                        systemImage: "pawprint",
                        description: Text("Tap + to hatch your first pet.")
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingNewPetSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPetSheet) {
                PetCreationView { pet in
                    navigateToPet = pet
                }
            }
        }
    }
}

#Preview {
    PetListView()
        .modelContainer(for: Pet.self, inMemory: true)
}
