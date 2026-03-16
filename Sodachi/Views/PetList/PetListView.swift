import SwiftUI
import SwiftData

struct PetListView: View {
    @Query(sort: \Pet.createdAt) private var pets: [Pet]
    @Environment(\.modelContext) private var context
    @State private var showingNewPetSheet = false

    private var alivePets: [Pet] { pets.filter { $0.lifecycleStage.isAlive } }
    private var deadPets: [Pet] { pets.filter { !$0.lifecycleStage.isAlive } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(alivePets) { pet in
                        NavigationLink(destination: Text("Game screen coming soon")) {
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
                NewPetSheet()
            }
        }
    }
}

// MARK: - New pet sheet (placeholder until issue #8)

private struct NewPetSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
            }
            .navigationTitle("New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        context.insert(Pet(name: name.trimmingCharacters(in: .whitespaces)))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    PetListView()
        .modelContainer(for: Pet.self, inMemory: true)
}
