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

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
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
}
