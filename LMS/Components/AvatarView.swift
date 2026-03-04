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

    var body: some View {
        if let url, let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                initialsView
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            initialsView
        }
    }

    private var initialsView: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.2))
            .frame(width: size, height: size)
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.35, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        AvatarView(url: nil, firstName: "Иван", lastName: "Петров")
        AvatarView(url: "https://example.com/avatar.jpg", firstName: "А", lastName: "Б", size: 60)
    }
}
