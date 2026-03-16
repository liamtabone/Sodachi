import SwiftUI

struct PetRowView: View {
    let pet: Pet
    private let theme = StaticImageTheme()

    var body: some View {
        HStack(spacing: 12) {
            petPreview
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name)
                    .font(.headline)
                Text(pet.lifecycleStage.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var petPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .frame(width: 52, height: 52)
            if let frame = theme.animation(for: pet.lifecycleStage, state: .idle).frames.first {
                frame
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }
        }
    }
}
