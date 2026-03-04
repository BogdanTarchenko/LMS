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
        ScrollView {
            VStack(spacing: 16) {
                if let error = vm.errorMessage {
                    ErrorBanner(message: error)
                }

                // Avatar
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    if let data = vm.avatarData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(.secondary)
                            }
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

                // Name fields
                validatedField("Имя", text: Bindable(vm).firstName, error: vm.firstNameError, id: "first_name_field")
                validatedField("Фамилия", text: Bindable(vm).lastName, error: vm.lastNameError, id: "last_name_field")

                // Email
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Email", text: Bindable(vm).email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("email_field")

                    if let error = vm.emailError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("email_error")
                    }
                }

                // Password
                VStack(alignment: .leading, spacing: 4) {
                    SecureField("Пароль", text: Bindable(vm).password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("password_field")

                    if let error = vm.passwordError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("password_error")
                    }
                }

                // Confirm Password
                VStack(alignment: .leading, spacing: 4) {
                    SecureField("Подтвердите пароль", text: Bindable(vm).confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("confirm_password_field")

                    if let error = vm.confirmPasswordError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("confirm_password_error")
                    }
                }

                // Date of Birth
                Toggle("Указать дату рождения", isOn: Bindable(vm).showDatePicker)
                    .tint(.accentColor)

                if vm.showDatePicker {
                    DatePicker("Дата рождения", selection: Bindable(vm).dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .accessibilityIdentifier("date_of_birth_picker")
                }

                // Register Button
                LoadingButton(title: "Зарегистрироваться", isLoading: vm.isLoading) {
                    Task {
                        await vm.register()
                    }
                }
                .accessibilityIdentifier("register_button")
            }
            .padding()
        }
    }

    @ViewBuilder
    private func validatedField(_ placeholder: String, text: Binding<String>, error: String?, id: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: text)
                .textContentType(.name)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier(id)

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
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
