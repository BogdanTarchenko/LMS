import SwiftUI

struct AssignmentCardView: View {
    let assignment: Assignment
    var role: Role = .student

    private var isTeacher: Bool { role == .owner || role == .teacher }

    private var accentColor: Color {
        if isTeacher {
            guard let deadline = assignment.deadline else { return .indigo }
            if Date() > deadline { return .red }
            return .indigo
        }
        switch assignment.submissionStatus {
        case .graded: return .green
        case .submitted: return .blue
        case .notSubmitted: return .orange
        case nil: return .indigo
        }
    }

    private var cardIcon: String {
        if isTeacher {
            guard let deadline = assignment.deadline else { return "doc.text.fill" }
            return Date() > deadline ? "clock.badge.xmark.fill" : "doc.text.fill"
        }
        switch assignment.submissionStatus {
        case .graded: return "checkmark.seal.fill"
        case .submitted: return "checkmark.circle.fill"
        case .notSubmitted: return "doc.text"
        case nil: return "doc.text"
        }
    }

    var body: some View {
        if isTeacher {
            teacherCard
        } else {
            studentCard
        }
    }

    private var teacherCard: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: cardIcon)
                        .font(.system(size: 18))
                        .foregroundStyle(accentColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let deadline = assignment.deadline {
                    DeadlineBadge(deadline: deadline, style: .compact)
                } else {
                    Text(assignment.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: accentColor.opacity(0.08), radius: 8, y: 3)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(accentColor)
                .frame(width: 3)
                .padding(.vertical, 10)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var studentCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.12))
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: cardIcon)
                        .font(.system(size: 18))
                        .foregroundStyle(accentColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let deadline = assignment.deadline {
                    DeadlineBadge(deadline: deadline, style: .compact)
                } else {
                    Text(assignment.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let status = assignment.submissionStatus {
                StatusBadge(status: status)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}

#Preview {
    VStack(spacing: 10) {
        AssignmentCardView(assignment: MockData.sampleAssignments[0], role: .student)
        AssignmentCardView(assignment: MockData.sampleAssignments[1], role: .student)
        AssignmentCardView(assignment: MockData.sampleAssignments[0], role: .teacher)
        AssignmentCardView(assignment: MockData.sampleAssignments[2], role: .owner)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
