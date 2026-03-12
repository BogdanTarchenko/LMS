import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(isLoading ? Color.accentColor.opacity(0.7) : Color.accentColor)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.15), value: isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        LoadingButton(title: "Войти", isLoading: false) {}
        LoadingButton(title: "Войти", isLoading: true) {}
    }
    .padding()
}
