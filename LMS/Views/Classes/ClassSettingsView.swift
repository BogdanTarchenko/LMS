import SwiftUI

struct ClassSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ClassDetailViewModel
    @State private var newName = ""
    @State private var showDeleteAlert = false
    @State private var isRenaming = false
    @State private var classDeleted = false

    private var isOwner: Bool {
        viewModel.classroom.myRole == .owner
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Реферальный код") {
                    HStack {
                        Text(viewModel.classroom.code)
                            .font(.title2)
                            .fontDesign(.monospaced)
                            .fontWeight(.semibold)

                        Spacer()

                        Button {
                            UIPasteboard.general.string = viewModel.classroom.code
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }

                        ShareLink(item: "Присоединяйся к классу \"\(viewModel.classroom.name)\" по коду: \(viewModel.classroom.code)") {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }

                if isOwner {
                    Section("Переименовать") {
                        TextField("Новое название", text: $newName)
                        LoadingButton(title: "Сохранить", isLoading: isRenaming) {
                            Task {
                                isRenaming = true
                                let success = await viewModel.renameClass(to: newName.trimmingCharacters(in: .whitespaces))
                                isRenaming = false
                                if success {
                                    newName = ""
                                }
                            }
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    Section {
                        Button("Удалить класс", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .alert("Удалить класс?", isPresented: $showDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteClass()
                        if success {
                            classDeleted = true
                            dismiss()
                        }
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это действие нельзя отменить. Все задания и ответы будут удалены.")
            }
            .onAppear {
                newName = viewModel.classroom.name
            }
        }
    }
}

#Preview {
    ClassSettingsView(
        viewModel: ClassDetailViewModel(
            classroom: MockData.sampleClasses[0],
            apiService: MockAPIService()
        )
    )
}
