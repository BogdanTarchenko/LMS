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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.accentColor, .accentColor.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(systemName: "plus.square.fill.on.square.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                            }

                        Text("Новый класс")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 12)

                    AuthField(
                        placeholder: "Название класса",
                        text: $className,
                        icon: "textformat",
                        error: nil,
                        accessibilityId: "class_name_field"
                    )

                    LoadingButton(title: "Создать класс", isLoading: isLoading) {
                        Task {
                            isLoading = true
                            let success = await viewModel.createClass(name: className.trimmingCharacters(in: .whitespaces))
                            isLoading = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                    .accessibilityIdentifier("create_class_button")
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
