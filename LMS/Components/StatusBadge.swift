import SwiftUI

struct StatusBadge: View {
    let status: SubmissionStatus?

    private var title: String {
        switch status {
        case .notSubmitted, nil: "Не сдано"
        case .submitted: "Сдано"
        case .graded: "Оценено"
        }
    }

    private var color: Color {
        switch status {
        case .notSubmitted, nil: .orange
        case .submitted: .blue
        case .graded: .green
        }
    }

    private var icon: String {
        switch status {
        case .notSubmitted, nil: "clock"
        case .submitted: "checkmark.circle"
        case .graded: "star.circle"
        }
    }

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        StatusBadge(status: nil)
        StatusBadge(status: .notSubmitted)
        StatusBadge(status: .submitted)
        StatusBadge(status: .graded)
    }
    .padding()
}
