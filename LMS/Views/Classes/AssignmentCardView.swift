import SwiftUI

struct AssignmentCardView: View {
    let assignment: Assignment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(assignment.title)
                    .font(.headline)
                Spacer()
                if let status = assignment.submissionStatus {
                    StatusBadge(status: status)
                }
            }

            Text(assignment.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}

#Preview {
    VStack {
        AssignmentCardView(assignment: MockData.sampleAssignments[0])
        AssignmentCardView(assignment: MockData.sampleAssignments[2])
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
