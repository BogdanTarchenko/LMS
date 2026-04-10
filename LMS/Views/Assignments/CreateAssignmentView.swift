import SwiftUI
import UniformTypeIdentifiers

struct CreateAssignmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apiService) private var apiService
    @State private var viewModel: CreateAssignmentViewModel
    @State private var showFilePicker = false
    var onCreated: (() -> Void)?

    init(classId: String, onCreated: (() -> Void)? = nil) {
        _viewModel = State(initialValue: CreateAssignmentViewModel(classId: classId, apiService: APIService.shared))
        self.onCreated = onCreated
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                    }
                    titleSection
                    descriptionSection
                    deadlineSection
                    teamSection
                    filesSection
                    publishButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Новое задание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
            .sheet(isPresented: $showFilePicker) {
                DocumentPicker(allowsMultipleSelection: true) { files in
                    viewModel.selectedFiles.append(contentsOf: files)
                }
            }
            .onAppear {
                viewModel.apiService = apiService
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Заголовок", icon: "doc.text")

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Image(systemName: "textformat")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    TextField("Название задания", text: Bindable(viewModel).title)
                        .accessibilityIdentifier("assignment_title_field")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(viewModel.titleError != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )

                if let error = viewModel.titleError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.leading, 4)
                }
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Описание", icon: "text.alignleft")

            TextEditor(text: Bindable(viewModel).description)
                .frame(minHeight: 130)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .accessibilityIdentifier("assignment_description_field")
        }
    }

    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldLabel("Дедлайн", icon: "clock")

            VStack(spacing: 0) {
                Toggle(isOn: Bindable(viewModel).hasDeadline) {
                    Label("Установить дедлайн", systemImage: "calendar.badge.clock")
                        .font(.subheadline)
                }
                .tint(.accentColor)
                .padding(16)

                if viewModel.hasDeadline {
                    Divider()
                        .padding(.horizontal, 16)

                    DatePicker(
                        "Дата и время",
                        selection: Bindable(viewModel).deadline,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .padding(16)
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Командное задание", icon: "person.3")
            Toggle(isOn: Bindable(viewModel).isTeamBased) {
                Label("Задание для команд", systemImage: "person.3.fill")
                    .font(.subheadline)
            }
            .tint(.accentColor)
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var filesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldLabel("Файлы", icon: "paperclip")

            VStack(spacing: 8) {
                ForEach(Array(viewModel.selectedFiles.enumerated()), id: \.offset) { index, file in
                    fileRow(file: file, index: index)
                }

                Button {
                    showFilePicker = true
                } label: {
                    Label("Прикрепить файл", systemImage: "plus.circle")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private func fileRow(file: FileData, index: Int) -> some View {
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

    private var publishButton: some View {
        LoadingButton(title: "Опубликовать задание", isLoading: viewModel.isLoading) {
            Task {
                let success = await viewModel.createAssignment()
                if success {
                    onCreated?()
                    dismiss()
                }
            }
        }
    }

    private func fieldLabel(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
    }
}
