import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🥚")
                .font(.system(size: 80))
            Text("Hello, Tamagotchi!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Your adventure begins here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
