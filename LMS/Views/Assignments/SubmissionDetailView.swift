import SwiftUI

struct SubmissionDetailView: View {
    @State private var viewModel: SubmissionDetailViewModel

    init(submission: Submission) {
        _viewModel = State(initialValue: SubmissionDetailViewModel(submission: submission))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Student info
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.submission.studentName)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Сдано: \(viewModel.submission.submittedAt, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Answer
                if let text = viewModel.submission.text {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ответ")
                            .font(.headline)
                        Text(text)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                Divider()

                // Grade section
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Оценка")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("0-100", text: Bindable(viewModel).gradeText)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityIdentifier("grade_field")

                        if let error = viewModel.gradeError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    LoadingButton(title: "Оценить", isLoading: viewModel.isLoading) {
                        Task { let _ = await viewModel.gradeSubmission() }
                    }
                    .accessibilityIdentifier("grade_button")
                }
            }
            .padding()
        }
        .navigationTitle("Ответ студента")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SubmissionDetailView(submission: MockData.sampleSubmissions[0])
    }
}
