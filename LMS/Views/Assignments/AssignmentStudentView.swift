import SwiftUI

struct AssignmentStudentView: View {
    @State private var viewModel: AssignmentStudentViewModel

    init(assignment: Assignment) {
        _viewModel = State(initialValue: AssignmentStudentViewModel(assignment: assignment))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Assignment info
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.assignment.title)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(viewModel.assignment.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !viewModel.assignment.description.isEmpty {
                        Text(viewModel.assignment.description)
                            .font(.body)
                    }
                }

                Divider()

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                if viewModel.hasSubmitted, let submission = viewModel.submission {
                    // Submitted state
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ваш ответ")
                            .font(.headline)

                        if let text = submission.text {
                            Text(text)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        if let grade = submission.grade {
                            HStack {
                                Text("Оценка:")
                                    .font(.headline)
                                GradeView(grade: grade)
                            }
                        } else {
                            StatusBadge(status: .submitted)
                        }
                    }
                } else {
                    // Submit form
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ваш ответ")
                            .font(.headline)

                        TextEditor(text: Bindable(viewModel).answerText)
                            .frame(minHeight: 120)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityIdentifier("answer_text_field")

                        LoadingButton(title: "Отправить", isLoading: viewModel.isLoading) {
                            Task { await viewModel.submitAnswer() }
                        }
                        .accessibilityIdentifier("submit_answer_button")
                    }
                }
            }
            .padding()
        }
    }
}
