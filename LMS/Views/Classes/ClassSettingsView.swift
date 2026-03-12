import SwiftUI

struct ClassSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ClassDetailViewModel
    @State private var newName = ""
    @State private var showDeleteAlert = false
    @State private var showRegenerateAlert = false
    @State private var isRenaming = false
    @State private var isRegenerating = false
    @State private var codeCopied = false

    private var isOwner: Bool { viewModel.classroom.myRole == .owner }
    private var canManageCode: Bool { viewModel.classroom.myRole == .owner || viewModel.classroom.myRole == .teacher }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    codeSection

                    if isOwner {
                        renameSection
                        deleteSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Настройки класса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            newName = viewModel.classroom.name
        }
        .alert("Удалить класс?", isPresented: $showDeleteAlert) {
            Button("Удалить", role: .destructive) {
                Task {
                    let success = await viewModel.deleteClass()
                    if success { dismiss() }
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Это действие нельзя отменить. Все задания и ответы будут удалены.")
        }
        .alert("Обновить код приглашения?", isPresented: $showRegenerateAlert) {
            Button("Обновить", role: .destructive) {
                Task {
                    isRegenerating = true
                    await viewModel.regenerateCode()
                    isRegenerating = false
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Старый код перестанет работать. Новые участники смогут войти только по новому коду.")
        }
    }

    private var codeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Реферальный код", systemImage: "qrcode")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Text(viewModel.classroom.code)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .tracking(3)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Spacer()

                Button {
                    UIPasteboard.general.string = viewModel.classroom.code
                    withAnimation { codeCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { codeCopied = false }
                    }
                } label: {
                    Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                        .font(.subheadline)
                        .foregroundStyle(codeCopied ? .green : .accentColor)
                        .frame(width: 36, height: 36)
                        .background((codeCopied ? Color.green : Color.accentColor).opacity(0.1))
                        .clipShape(Circle())
                }
                .animation(.easeInOut(duration: 0.2), value: codeCopied)

                ShareLink(item: "Присоединяйся к классу \"\(viewModel.classroom.name)\" по коду: \(viewModel.classroom.code)") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 36, height: 36)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Circle())
                }

                if canManageCode {
                    Button {
                        showRegenerateAlert = true
                    } label: {
                        if isRegenerating {
                            ProgressView()
                                .frame(width: 36, height: 36)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                                .frame(width: 36, height: 36)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .disabled(isRegenerating)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var renameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Переименовать класс", systemImage: "pencil")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                AuthField(
                    placeholder: "Новое название",
                    text: $newName,
                    icon: "textformat",
                    error: nil,
                    accessibilityId: "rename_class_field"
                )

                LoadingButton(title: "Сохранить", isLoading: isRenaming) {
                    Task {
                        isRenaming = true
                        let success = await viewModel.renameClass(to: newName.trimmingCharacters(in: .whitespaces))
                        isRenaming = false
                        if success { newName = viewModel.classroom.name }
                    }
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            Label("Удалить класс", systemImage: "trash")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
