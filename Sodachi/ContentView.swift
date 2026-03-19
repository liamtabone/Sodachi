import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var pets: [Pet]
    #if DEBUG
    @AppStorage("useRetroUI") private var useRetroUI = false
    #endif

    var body: some View {
        content
        #if DEBUG
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
                useRetroUI.toggle()
            }
            .overlay(alignment: .bottom) {
                Text(useRetroUI ? "Retro UI" : "Dev UI")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 8)
            }
        #endif
    }

    @ViewBuilder
    private var content: some View {
        #if DEBUG
        if useRetroUI {
            RetroUIPlaceholder()
        } else {
            devUI
        }
        #else
        devUI
        #endif
    }

    @ViewBuilder
    private var devUI: some View {
        if let pet = pets.first {
            GameScreenView(pet: pet)
        } else {
            PetCreationView()
        }
    }
}

#if DEBUG
private struct RetroUIPlaceholder: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Retro UI\nComing Soon")
                .font(.system(.title, design: .monospaced))
                .foregroundStyle(.green)
                .multilineTextAlignment(.center)
        }
    }
}
#endif

#Preview {
    ContentView()
        .modelContainer(for: Pet.self, inMemory: true)
}
