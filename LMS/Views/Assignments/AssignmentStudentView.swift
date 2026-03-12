import SwiftUI

struct AssignmentStudentView: View {
    @State private var viewModel: AssignmentStudentViewModel
    @State private var showFilePicker = false
    @State private var showAssignmentFilePicker = false

    init(assignment: Assignment) {
        _viewModel = State(initialValue: AssignmentStudentViewModel(assignment: assignment))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                assignmentInfoSection

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                        .padding(.horizontal, 20)
                }

                if viewModel.isLoading && viewModel.submission == nil && !viewModel.isEditing {
                    ProgressView()
                        .padding(40)
                } else if viewModel.hasSubmitted && !viewModel.isEditing {
                    submittedSection
                } else {
                    submitFormSection
                }

                commentsSection
            }
            .padding(.bottom, 32)
        }
        .task {
            await viewModel.loadMySubmission()
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker(allowsMultipleSelection: true) { files in
                viewModel.addFiles(files)
            }
        }
    }

    private var assignmentInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.assignment.title)
                    .font(.title2)
                    .fontWeight(.bold)

                if let deadline = viewModel.assignment.deadline {
                    DeadlineBadge(deadline: deadline)
                }

                if !viewModel.assignment.description.isEmpty {
                    Text(viewModel.assignment.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let fileUrls = viewModel.assignment.fileUrls, !fileUrls.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Прикреплённые файлы", systemImage: "paperclip")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        ForEach(fileUrls, id: \.self) { url in
                            FileAttachmentView(fileURLString: url)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var submittedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Label("Ваш ответ", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)

                if let submission = viewModel.submission {
                    if let text = submission.text {
                        Text(text)
                            .font(.body)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let fileUrls = submission.fileUrls, !fileUrls.isEmpty {
                        VStack(spacing: 6) {
                            ForEach(fileUrls, id: \.self) { url in
                                FileAttachmentView(fileURLString: url)
                            }
                        }
                    }

                    if let grade = submission.grade {
                        HStack {
                            Text("Оценка")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            GradeView(grade: grade)
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        StatusBadge(status: .submitted)
                    }

                    if viewModel.canSubmit {
                        HStack(spacing: 12) {
                            if submission.grade == nil {
                                Button {
                                    viewModel.startEditing()
                                } label: {
                                    Label("Редактировать", systemImage: "pencil")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.accentColor.opacity(0.1))
                                        .foregroundStyle(Color.accentColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }

                            if viewModel.canCancel {
                                Button(role: .destructive) {
                                    Task { await viewModel.cancelSubmission() }
                                } label: {
                                    Label("Отменить", systemImage: "xmark")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundStyle(.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        .padding(.horizontal, 16)
    }

    private var submitFormSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Label(
                    viewModel.isEditing ? "Редактирование ответа" : "Ваш ответ",
                    systemImage: viewModel.isEditing ? "pencil.circle.fill" : "square.and.pencil"
                )
                .font(.headline)

                if viewModel.isDeadlinePassed {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("Дедлайн прошёл. Сдача невозможна.")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                    .padding(14)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    TextEditor(text: Bindable(viewModel).answerText)
                        .frame(minHeight: 130)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityIdentifier("answer_text_field")

                    VStack(spacing: 8) {
                        ForEach(Array(viewModel.attachedFiles.enumerated()), id: \.offset) { index, file in
                            HStack(spacing: 10) {
                                Image(systemName: "doc.fill")
                                    .foregroundStyle(Color.accentColor)
                                Text(file.fileName)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button {
                                    viewModel.removeFile(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.7))
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        Button {
                            showFilePicker = true
                        } label: {
                            Label("Прикрепить файл", systemImage: "paperclip")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 12) {
                        LoadingButton(
                            title: viewModel.isEditing ? "Сохранить" : "Отправить",
                            isLoading: viewModel.isLoading
                        ) {
                            Task { await viewModel.submitAnswer() }
                        }
                        .accessibilityIdentifier("submit_answer_button")

                        if viewModel.isEditing {
                            Button("Отмена") {
                                viewModel.isEditing = false
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        .padding(.horizontal, 16)
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            CommentsSection(assignmentId: viewModel.assignment.id)
                .padding(20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        .padding(.horizontal, 16)
    }
}

