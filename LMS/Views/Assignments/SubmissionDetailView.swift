import SwiftUI

struct SubmissionDetailView: View {
    @Environment(\.apiService) private var apiService
    @State private var viewModel: SubmissionDetailViewModel

    init(submission: Submission) {
        _viewModel = State(initialValue: SubmissionDetailViewModel(submission: submission, apiService: APIService.shared))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                studentInfoSection

                if let text = viewModel.submission.text {
                    answerTextSection(text)
                }

                if let fileUrls = viewModel.submission.fileUrls, !fileUrls.isEmpty {
                    filesSection(fileUrls)
                }

                gradeSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .navigationTitle("Ответ студента")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.apiService = apiService
        }
    }

    private var studentInfoSection: some View {
        HStack(spacing: 14) {
            AvatarView(
                url: viewModel.submission.studentAvatarUrl,
                firstName: viewModel.submission.studentName.components(separatedBy: " ").first ?? "",
                lastName: viewModel.submission.studentName.components(separatedBy: " ").last ?? "",
                size: 52
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.submission.studentName)
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("Сдано \(viewModel.submission.submittedAt, style: .date)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            if let grade = viewModel.submission.grade {
                GradeView(grade: grade)
            } else {
                StatusBadge(status: .submitted)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func answerTextSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Ответ студента", systemImage: "text.quote")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text(text)
                .font(.body)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func filesSection(_ fileUrls: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Прикреплённые файлы", systemImage: "paperclip")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ForEach(fileUrls, id: \.self) { url in
                FileAttachmentView(fileURLString: url)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private var gradeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Выставить оценку", systemImage: "star.circle")
                .font(.headline)

            if let error = viewModel.errorMessage {
                ErrorBanner(message: error)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Image(systemName: "number")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    TextField("0–100", text: Bindable(viewModel).gradeText)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("grade_field")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(viewModel.gradeError != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )

                if let error = viewModel.gradeError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.leading, 4)
                }
            }

            LoadingButton(title: "Оценить", isLoading: viewModel.isLoading) {
                Task { let _ = await viewModel.gradeSubmission() }
            }
            .accessibilityIdentifier("grade_button")
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

#Preview {
    NavigationStack {
        SubmissionDetailView(submission: MockData.sampleSubmissions[0])
    }
}
