import SwiftUI

struct SubmissionRowView: View {
    let submission: Submission

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(submission.studentName)
                    .font(.body)

                Text(submission.submittedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let grade = submission.grade {
                GradeView(grade: grade)
            } else {
                StatusBadge(status: .submitted)
            }
        }
    }
}

#Preview {
    List {
        SubmissionRowView(submission: MockData.sampleSubmissions[0])
        SubmissionRowView(submission: MockData.sampleSubmissions[1])
    }
}
