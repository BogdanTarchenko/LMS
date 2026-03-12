import SwiftUI

struct JoinClassSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ClassListViewModel
    @State private var code = ""
    @State private var isLoading = false

    private var isValid: Bool {
        code.trimmingCharacters(in: .whitespaces).count == 8
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.teal, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(systemName: "arrow.right.square.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                            }

                        VStack(spacing: 6) {
                            Text("Войти в класс")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Введите 8-символьный код от преподавателя")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 12) {
                            Image(systemName: "number")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)

                            TextField("ABCD1234", text: $code)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                                .font(.system(.body, design: .monospaced))
                                .accessibilityIdentifier("join_code_field")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 15)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    LoadingButton(title: "Присоединиться", isLoading: isLoading) {
                        Task {
                            isLoading = true
                            let success = await viewModel.joinClass(code: code.trimmingCharacters(in: .whitespaces))
                            isLoading = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
