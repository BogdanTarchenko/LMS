import SwiftUI

struct SubmissionRowView: View {
    let submission: Submission

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                url: submission.studentAvatarUrl,
                firstName: submission.studentName.components(separatedBy: " ").first ?? "",
                lastName: submission.studentName.components(separatedBy: " ").last ?? "",
                size: 40
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(submission.studentName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(submission.submittedAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let fileUrls = submission.fileUrls, !fileUrls.isEmpty {
                        Image(systemName: "paperclip")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if let grade = submission.grade {
                GradeView(grade: grade)
            } else {
                StatusBadge(status: .submitted)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        SubmissionRowView(submission: MockData.sampleSubmissions[0])
        SubmissionRowView(submission: MockData.sampleSubmissions[1])
    }
}
