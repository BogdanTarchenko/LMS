import SwiftUI
import UniformTypeIdentifiers

struct AssignmentStudentView: View {
    @State private var viewModel: AssignmentStudentViewModel
    @State private var showFilePicker = false

    init(assignment: Assignment) {
        _viewModel = State(initialValue: AssignmentStudentViewModel(assignment: assignment))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                assignmentInfoSection

                Divider()

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                if viewModel.isLoading && viewModel.submission == nil && !viewModel.isEditing {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewModel.hasSubmitted && !viewModel.isEditing {
                    submittedSection
                } else {
                    submitFormSection
                }

                Divider()

                CommentsSection(assignmentId: viewModel.assignment.id)
            }
            .padding()
        }
        .task {
            await viewModel.loadMySubmission()
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker { data, name in
                viewModel.fileData = data
                viewModel.fileName = name
            }
        }
    }

    // MARK: - Assignment Info

    @ViewBuilder
    private var assignmentInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.assignment.title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.assignment.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let deadline = viewModel.assignment.deadline {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("Дедлайн:")
                    Text(deadline, style: .date)
                    Text(deadline, style: .time)
                }
                .font(.caption)
                .foregroundStyle(viewModel.isDeadlinePassed ? .red : .orange)
            }

            if !viewModel.assignment.description.isEmpty {
                Text(viewModel.assignment.description)
                    .font(.body)
            }
        }
    }

    // MARK: - Submitted State

    @ViewBuilder
    private var submittedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ваш ответ")
                .font(.headline)

            if let submission = viewModel.submission {
                if let text = submission.text {
                    Text(text)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if let fileURL = submission.fileURL {
                    Label(fileURL.components(separatedBy: "/").last ?? "Файл", systemImage: "paperclip")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
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

                if viewModel.canSubmit {
                    HStack(spacing: 12) {
                        if submission.grade == nil {
                            Button("Редактировать") {
                                viewModel.startEditing()
                            }
                        }

                        if viewModel.canCancel {
                            Button("Отменить ответ", role: .destructive) {
                                Task { await viewModel.cancelSubmission() }
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Submit / Edit Form

    @ViewBuilder
    private var submitFormSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.isEditing ? "Редактирование ответа" : "Ваш ответ")
                .font(.headline)

            if viewModel.isDeadlinePassed {
                Text("Дедлайн прошёл. Сдача невозможна.")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            } else {
                TextEditor(text: Bindable(viewModel).answerText)
                    .frame(minHeight: 120)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityIdentifier("answer_text_field")

                HStack {
                    Button {
                        showFilePicker = true
                    } label: {
                        Label(viewModel.fileName ?? "Прикрепить файл", systemImage: "paperclip")
                    }

                    if viewModel.fileName != nil {
                        Button(role: .destructive) {
                            viewModel.fileData = nil
                            viewModel.fileName = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }

                HStack(spacing: 12) {
                    LoadingButton(title: viewModel.isEditing ? "Сохранить" : "Отправить", isLoading: viewModel.isLoading) {
                        Task { await viewModel.submitAnswer() }
                    }
                    .accessibilityIdentifier("submit_answer_button")

                    if viewModel.isEditing {
                        Button("Отмена") {
                            viewModel.isEditing = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (Data, String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (Data, String) -> Void

        init(onPick: @escaping (Data, String) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            if let data = try? Data(contentsOf: url) {
                onPick(data, url.lastPathComponent)
            }
        }
    }
}
