import SwiftUI
import SwiftData

@main
struct SodachiApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Pet.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                processDecay()
            }
        }
    }

    private func processDecay() {
        let context = container.mainContext
        let decayEngine = DecayEngine()
        let lifecycleEngine = LifecycleEngine()
        do {
            let pets = try context.fetch(FetchDescriptor<Pet>())
            decayEngine.processAll(pets: pets)
            lifecycleEngine.evaluateAll(pets: pets)
            try context.save()
        } catch {
            print("Decay/lifecycle engine failed: \(error)")
        }
    }
}
