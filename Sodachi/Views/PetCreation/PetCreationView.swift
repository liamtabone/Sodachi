import SwiftUI
import SwiftData

struct PetCreationView: View {
    let onCreated: (Pet) -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedThemeID = StaticImageTheme.themeID

    private var selectedTheme: any PetVisualTheme {
        ThemeRegistry.theme(for: selectedThemeID)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Your pet's name", text: $name)
                }

                Section("Theme") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ThemeRegistry.available, id: \.themeID) { theme in
                                ThemeCard(theme: theme, isSelected: theme.themeID == selectedThemeID) {
                                    selectedThemeID = theme.themeID
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 2)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createPet() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var petPreview: some View {
        let animation = selectedTheme.animation(for: .egg, state: .idle)
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
            visualThemeID: selectedThemeID
        )
        context.insert(pet)
        onCreated(pet)
        dismiss()
    }
}

// MARK: - Theme card

private struct ThemeCard: View {
    let theme: any PetVisualTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let animation = theme.animation(for: .egg, state: .idle)
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                        .frame(width: 72, height: 72)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                        }
                    if let frame = animation.frames.first {
                        frame
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                    }
                }
                Text(theme.name)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .accent : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PetCreationView { _ in }
        .modelContainer(for: Pet.self, inMemory: true)
}
