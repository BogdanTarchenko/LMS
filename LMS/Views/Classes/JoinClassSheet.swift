import SwiftUI

struct JoinClassSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ClassListViewModel
    @State private var code = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Код класса", text: $code)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .accessibilityIdentifier("join_code_field")
                } footer: {
                    Text("Введите 8-символьный код класса")
                }

                Section {
                    LoadingButton(title: "Присоединиться", isLoading: isLoading) {
                        Task {
                            isLoading = true
                            let success = await viewModel.joinClass(code: code.trimmingCharacters(in: .whitespaces))
                            isLoading = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Присоединиться")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
