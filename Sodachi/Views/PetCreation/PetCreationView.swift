import SwiftUI
import SwiftData

struct PetCreationView: View {
    @Environment(\.modelContext) private var context
    @State private var name = ""
    @State private var selectedSpeciesID = DogSpecies.speciesID

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Your pet's name", text: $name)
                }

                Section("Species") {
                    Picker("Species", selection: $selectedSpeciesID) {
                        ForEach(SpeciesRegistry.available, id: \.speciesID) { species in
                            Text(species.displayName).tag(species.speciesID)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Preview") {
                    HStack {
                        Spacer()
                        petPreview
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createPet() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var petPreview: some View {
        let theme = ThemeRegistry.theme(for: StaticImageTheme.themeID)
        let animation = theme.animation(for: .egg, state: .idle)
        return ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
                .frame(width: 120, height: 120)
            if let frame = animation.frames.first {
                frame
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
            }
        }
    }

    private func createPet() {
        let pet = Pet(
            name: name.trimmingCharacters(in: .whitespaces),
            species: selectedSpeciesID,
            visualThemeID: StaticImageTheme.themeID
        )
        context.insert(pet)
        try? context.save()
    }
}

#Preview {
    PetCreationView()
        .modelContainer(for: Pet.self, inMemory: true)
}
