import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel: LoginViewModel?
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("LMS")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Система управления обучением")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let vm = viewModel {
                    loginForm(vm)
                }

                Spacer()

                HStack {
                    Text("Нет аккаунта?")
                        .foregroundStyle(.secondary)
                    Button("Зарегистрироваться") {
                        showRegister = true
                    }
                }
                .font(.callout)
            }
            .padding()
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LoginViewModel(authManager: authManager)
            }
        }
    }

    @ViewBuilder
    private func loginForm(_ vm: LoginViewModel) -> some View {
        VStack(spacing: 16) {
            if let error = vm.errorMessage {
                ErrorBanner(message: error)
            }

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

            VStack(alignment: .leading, spacing: 4) {
                SecureField("Пароль", text: Bindable(vm).password)
                    .textContentType(.password)
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

            LoadingButton(title: "Войти", isLoading: vm.isLoading) {
                Task {
                    await vm.login()
                }
            }
            .accessibilityIdentifier("login_button")
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager(apiService: MockAPIService(), keychainHelper: MockKeychainHelper()))
}
