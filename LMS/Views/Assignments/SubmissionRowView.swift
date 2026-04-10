import SwiftUI

struct SubmissionRowView: View {
    let submission: Submission

    var body: some View {
        HStack(spacing: 12) {
            if submission.teamName != nil {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            } else {
                AvatarView(
                    url: submission.studentAvatarUrl,
                    firstName: submission.studentName.components(separatedBy: " ").first ?? "",
                    lastName: submission.studentName.components(separatedBy: " ").last ?? "",
                    size: 40
                )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(submission.displayName)
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
