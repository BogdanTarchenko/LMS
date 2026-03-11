import SwiftUI

struct CreateAssignmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateAssignmentViewModel
    var onCreated: (() -> Void)?

    init(classId: String, onCreated: (() -> Void)? = nil) {
        _viewModel = State(initialValue: CreateAssignmentViewModel(classId: classId))
        self.onCreated = onCreated
    }

    var body: some View {
        NavigationStack {
            Form {
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Заголовок", text: Bindable(viewModel).title)
                            .accessibilityIdentifier("assignment_title_field")

                        if let error = viewModel.titleError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section("Описание") {
                    TextEditor(text: Bindable(viewModel).description)
                        .frame(minHeight: 120)
                        .accessibilityIdentifier("assignment_description_field")
                }

                Section("Дедлайн") {
                    Toggle("Установить дедлайн", isOn: Bindable(viewModel).hasDeadline)

                    if viewModel.hasDeadline {
                        DatePicker(
                            "Дата и время",
                            selection: Bindable(viewModel).deadline,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                Section {
                    LoadingButton(title: "Опубликовать", isLoading: viewModel.isLoading) {
                        Task {
                            let success = await viewModel.createAssignment()
                            if success {
                                onCreated?()
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новое задание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
