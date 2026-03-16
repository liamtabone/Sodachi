import SwiftUI
import SwiftData

struct GameScreenView: View {
    let pet: Pet
    @Environment(\.modelContext) private var context
    @State private var overrideVisualState: PetVisualState?
    private var theme: any PetVisualTheme { ThemeRegistry.theme(for: pet.visualThemeID) }
    private var displayVisualState: PetVisualState { overrideVisualState ?? pet.visualState }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                petDisplay
                if let stats = pet.stats {
                    StatsHUDView(stats: stats)
                }
                ActionButtonsView(pet: pet, onVisualStateChange: { state in
                    overrideVisualState = state
                })
            }
            .padding()
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var petDisplay: some View {
        let animation = theme.animation(for: pet.lifecycleStage, state: displayVisualState)
        return ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
                .frame(height: 200)
            if let frame = animation.frames.first {
                frame
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
            } else {
                // Placeholder until real assets are added (issue #5)
                Text(placeholderEmoji)
                    .font(.system(size: 80))
            }
        }
    }

    private var placeholderEmoji: String {
        switch pet.lifecycleStage {
        case .egg:    return "🥚"
        case .baby:   return "🐣"
        case .child:  return "🐥"
        case .teen:   return "🐤"
        case .adult:  return "🐓"
        case .senior: return "🦆"
        case .dead:   return "💀"
        }
    }
}

// MARK: - Stats HUD

private struct StatsHUDView: View {
    let stats: PetStats

    var body: some View {
        VStack(spacing: 12) {
            Text("Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            statRow(label: "Hunger",    value: stats.hunger,    icon: "fork.knife")
            statRow(label: "Happiness", value: stats.happiness, icon: "face.smiling")
            statRow(label: "Health",    value: stats.health,    icon: "heart.fill")
            statRow(label: "Energy",    value: stats.energy,    icon: "bolt.fill")

            Divider()

            HStack {
                Label("Age", systemImage: "clock")
                    .font(.subheadline)
                Spacer()
                Text(formattedAge(stats.age))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Label("Weight", systemImage: "scalemass")
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.1f", stats.weight))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func statRow(label: String, value: Double, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.0f", value))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: value, total: 100)
                .tint(statColor(value))
        }
    }

    private func statColor(_ value: Double) -> Color {
        if value < 20 { return .red }
        if value < 50 { return .orange }
        return .green
    }

    private func formattedAge(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        return hours < 24 ? "\(hours)h" : "\(hours / 24)d"
    }
}

// MARK: - Action buttons

private struct ActionButtonsView: View {
    let pet: Pet
    let onVisualStateChange: (PetVisualState?) -> Void

    @Environment(\.modelContext) private var context
    @State private var showingFeedMenu = false
    private let feedAction = FeedAction()

    private struct Action: Identifiable {
        let id = UUID()
        let label: String
        let icon: String
    }

    private let actions: [Action] = [
        .init(label: "Feed",       icon: "fork.knife"),
        .init(label: "Play",       icon: "gamecontroller"),
        .init(label: "Sleep",      icon: "moon.fill"),
        .init(label: "Clean",      icon: "sparkles"),
        .init(label: "Medicine",   icon: "cross.case"),
        .init(label: "Discipline", icon: "hand.raised"),
        .init(label: "Toilet",     icon: "toilet"),
    ]

    var body: some View {
        VStack(spacing: 12) {
            Text("Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(actions) { action in
                    Button { handleTap(action.label) } label: {
                        VStack(spacing: 4) {
                            Image(systemName: action.icon)
                                .font(.title2)
                            Text(action.label)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .confirmationDialog("What would you like to feed?", isPresented: $showingFeedMenu) {
            Button("Meal")  { performFeed(.meal) }
            Button("Snack") { performFeed(.snack) }
            Button("Cancel", role: .cancel) { }
        }
    }

    private func handleTap(_ label: String) {
        if label == "Feed" { showingFeedMenu = true }
        // Other actions implemented in issues #10–15
    }

    private func performFeed(_ foodType: FeedAction.FoodType) {
        onVisualStateChange(.eating)
        feedAction.feed(pet: pet, foodType: foodType)
        try? context.save()
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run { onVisualStateChange(nil) }
        }
    }
}

#Preview {
    NavigationStack {
        GameScreenView(pet: {
            let pet = Pet(name: "Taro")
            return pet
        }())
    }
    .modelContainer(for: Pet.self, inMemory: true)
}
