import SwiftUI

struct CreateClassSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ClassListViewModel
    @State private var className = ""
    @State private var isLoading = false

    private var isValid: Bool {
        !className.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Название класса", text: $className)
                        .accessibilityIdentifier("class_name_field")
                }

                Section {
                    LoadingButton(title: "Создать", isLoading: isLoading) {
                        Task {
                            isLoading = true
                            let success = await viewModel.createClass(name: className.trimmingCharacters(in: .whitespaces))
                            isLoading = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Новый класс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
