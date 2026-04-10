import SwiftUI
import PhotosUI

struct RegisterView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RegisterViewModel?
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        Group {
            if let vm = viewModel {
                registerForm(vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Регистрация")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if viewModel == nil {
                viewModel = RegisterViewModel(authManager: authManager)
            }
        }
    }

    @ViewBuilder
    private func registerForm(_ vm: RegisterViewModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                if let error = vm.errorMessage {
                    ErrorBanner(message: error)
                }

                avatarPicker(vm)

                VStack(spacing: 12) {
                    AuthField(
                        placeholder: "Имя",
                        text: Bindable(vm).firstName,
                        icon: "person",
                        textContentType: .givenName,
                        error: vm.firstNameError,
                        accessibilityId: "first_name_field"
                    )

                    AuthField(
                        placeholder: "Фамилия",
                        text: Bindable(vm).lastName,
                        icon: "person",
                        textContentType: .familyName,
                        error: vm.lastNameError,
                        accessibilityId: "last_name_field"
                    )

                    AuthField(
                        placeholder: "Email",
                        text: Bindable(vm).email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        error: vm.emailError,
                        accessibilityId: "email_field",
                        errorAccessibilityId: "email_error"
                    )

                    AuthSecureField(
                        placeholder: "Пароль",
                        text: Bindable(vm).password,
                        icon: "lock",
                        error: vm.passwordError,
                        accessibilityId: "password_field",
                        errorAccessibilityId: "password_error"
                    )

                    AuthSecureField(
                        placeholder: "Подтвердите пароль",
                        text: Bindable(vm).confirmPassword,
                        icon: "lock.shield",
                        error: vm.confirmPasswordError,
                        accessibilityId: "confirm_password_field",
                        errorAccessibilityId: "confirm_password_error"
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: Bindable(vm).showDatePicker) {
                        Label("Указать дату рождения", systemImage: "calendar")
                            .font(.subheadline)
                    }
                    .tint(.accentColor)

                    if vm.showDatePicker {
                        DatePicker(
                            "Дата рождения",
                            selection: Bindable(vm).dateOfBirth,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .accessibilityIdentifier("date_of_birth_picker")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                LoadingButton(title: "Зарегистрироваться", isLoading: vm.isLoading) {
                    Task { await vm.register() }
                }
                .accessibilityIdentifier("register_button")
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }

    @ViewBuilder
    private func avatarPicker(_ vm: RegisterViewModel) -> some View {
        let avatarData = vm.avatarData
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Group {
                if let data = avatarData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 96, height: 96)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 2, y: 2)
            }
        }
        .accessibilityIdentifier("avatar_picker")
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    vm.avatarData = data
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environment(AuthManager(apiService: MockAPIService(), keychainHelper: MockKeychainHelper()))
    }
}
