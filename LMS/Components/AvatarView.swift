import SwiftUI

struct AvatarView: View {
    let url: String?
    let firstName: String
    let lastName: String
    var size: CGFloat = 40

    private var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)".uppercased()
    }

    private var resolvedURL: URL? {
        guard let url else { return nil }
        return APIConfig.resolveFileURL(url)
    }

    private var gradientColors: [Color] {
        let hash = abs((firstName + lastName).hashValue)
        let palettes: [[Color]] = [
            [.blue, .cyan],
            [.purple, .pink],
            [.orange, .red],
            [.teal, .green],
            [.indigo, .blue],
        ]
        return palettes[hash % palettes.count]
    }

    var body: some View {
        if let imageURL = resolvedURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                default:
                    initialsView
                }
            }
        } else {
            initialsView
        }
    }

    private var initialsView: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
    }
}

#Preview {
    HStack(spacing: 16) {
        AvatarView(url: nil, firstName: "Иван", lastName: "Петров", size: 56)
        AvatarView(url: nil, firstName: "Анна", lastName: "Смирнова", size: 56)
        AvatarView(url: nil, firstName: "Максим", lastName: "Козлов", size: 56)
    }
    .padding()
}
