import SwiftUI

struct DeadlineBadge: View {
    let deadline: Date
    var style: Style = .full

    enum Style {
        case full
        case compact
    }

    private var isPassed: Bool { Date() > deadline }

    private var timeRemaining: String {
        let diff = deadline.timeIntervalSince(Date())
        if diff <= 0 { return "Истёк" }
        let hours = Int(diff) / 3600
        let days = hours / 24
        if days > 1 { return "Осталось \(days) д." }
        if hours > 0 { return "Осталось \(hours) ч." }
        let minutes = Int(diff) / 60
        return "Осталось \(minutes) мин."
    }

    private var accentColor: Color {
        if isPassed { return .red }
        let hours = deadline.timeIntervalSince(Date()) / 3600
        if hours < 24 { return .red }
        if hours < 72 { return .orange }
        return .secondary
    }

    private var icon: String {
        if isPassed { return "clock.badge.xmark" }
        let hours = deadline.timeIntervalSince(Date()) / 3600
        if hours < 24 { return "exclamationmark.circle.fill" }
        return "clock"
    }

    var body: some View {
        switch style {
        case .full:
            fullView
        case .compact:
            compactView
        }
    }

    private var fullView: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(deadline, style: .date)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Text("·")
                .font(.caption)
                .foregroundStyle(accentColor.opacity(0.5))
            Spacer()
            Text(timeRemaining)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
        .foregroundStyle(accentColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(accentColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var compactView: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
            Text(deadline, style: .date)
                .font(.caption)
            if !isPassed {
                Text("·")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(timeRemaining)
                    .font(.caption)
            }
        }
        .foregroundStyle(accentColor)
    }
}

#Preview {
    VStack(spacing: 12) {
        DeadlineBadge(deadline: Date().addingTimeInterval(30 * 60))
        DeadlineBadge(deadline: Date().addingTimeInterval(10 * 3600))
        DeadlineBadge(deadline: Date().addingTimeInterval(5 * 24 * 3600))
        DeadlineBadge(deadline: Date().addingTimeInterval(-3600))
        DeadlineBadge(deadline: Date().addingTimeInterval(2 * 3600), style: .compact)
        DeadlineBadge(deadline: Date().addingTimeInterval(-3600), style: .compact)
    }
    .padding()
}
