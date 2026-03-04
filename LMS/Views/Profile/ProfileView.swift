import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel: ProfileViewModel?
    @State private var showLogoutAlert = false

    var body: some View {
        Group {
            if let vm = viewModel {
                profileContent(vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Профиль")
        .onAppear {
            if viewModel == nil {
                viewModel = ProfileViewModel(authManager: authManager)
            }
        }
    }

    @ViewBuilder
    private func profileContent(_ vm: ProfileViewModel) -> some View {
        Form {
            if let error = vm.errorMessage {
                ErrorBanner(message: error)
            }

            if let user = vm.user {
                Section {
                    HStack {
                        Spacer()
                        AvatarView(
                            url: user.avatarURL,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            size: 80
                        )
                        Spacer()
                    }
                }

                Section("Личные данные") {
                    if vm.isEditing {
                        TextField("Имя", text: Bindable(vm).firstName)
                            .accessibilityIdentifier("profile_first_name")
                        TextField("Фамилия", text: Bindable(vm).lastName)
                            .accessibilityIdentifier("profile_last_name")
                    } else {
                        LabeledContent("Имя", value: user.firstName)
                        LabeledContent("Фамилия", value: user.lastName)
                    }

                    LabeledContent("Email", value: user.email)

                    if let dob = user.dateOfBirth {
                        LabeledContent("Дата рождения") {
                            Text(dob, style: .date)
                        }
                    }
                }

                Section {
                    if vm.isEditing {
                        LoadingButton(title: "Сохранить", isLoading: vm.isLoading) {
                            Task { let _ = await vm.updateProfile() }
                        }

                        Button("Отмена") {
                            vm.isEditing = false
                            vm.firstName = user.firstName
                            vm.lastName = user.lastName
                        }
                    } else {
                        Button("Редактировать") {
                            vm.isEditing = true
                        }
                    }
                }

                Section {
                    Button("Выйти", role: .destructive) {
                        showLogoutAlert = true
                    }
                    .accessibilityIdentifier("logout_button")
                }
            } else if vm.isLoading {
                ProgressView()
            }
        }
        .alert("Выйти из аккаунта?", isPresented: $showLogoutAlert) {
            Button("Выйти", role: .destructive) {
                vm.logout()
            }
            Button("Отмена", role: .cancel) {}
        }
        .task {
            await vm.loadProfile()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(AuthManager(apiService: MockAPIService(), keychainHelper: MockKeychainHelper()))
    }
}
