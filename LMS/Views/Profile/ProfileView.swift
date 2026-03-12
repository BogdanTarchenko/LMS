import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.apiService) private var apiService
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
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if viewModel == nil {
                viewModel = ProfileViewModel(authManager: authManager, apiService: apiService)
            }
        }
    }

    @ViewBuilder
    private func profileContent(_ vm: ProfileViewModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                if let error = vm.errorMessage {
                    ErrorBanner(message: error)
                        .padding(.horizontal, 20)
                }

                if let user = vm.user {
                    avatarHeaderSection(vm: vm, user: user)
                    infoSection(vm: vm, user: user)
                    actionSection(vm: vm)
                    logoutSection
                } else if vm.isLoading {
                    ProgressView()
                        .padding(40)
                }
            }
            .padding(.bottom, 32)
        }
        .task {
            await vm.loadProfile()
        }
        .alert("Выйти из аккаунта?", isPresented: $showLogoutAlert) {
            Button("Выйти", role: .destructive) { vm.logout() }
            Button("Отмена", role: .cancel) {}
        }
        .confirmationDialog("Изменить аватарку", isPresented: Bindable(vm).showAvatarOptions, titleVisibility: .visible) {
            Button("Выбрать из галереи") {
                vm.showPhotoPicker = true
            }
            Button("Вставить ссылку") {
                vm.promptAvatarURL()
            }
            Button("Отмена", role: .cancel) {}
        }
        .photosPicker(isPresented: Bindable(vm).showPhotoPicker, selection: Bindable(vm).selectedPhotoItem, matching: .images)
        .alert("Ссылка на аватарку", isPresented: Bindable(vm).showAvatarAlert) {
            TextField("https://example.com/avatar.jpg", text: Bindable(vm).avatarUrlText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Сохранить") {}
            Button("Отмена", role: .cancel) {
                vm.avatarUrlText = ""
            }
        } message: {
            Text("Вставьте ссылку на изображение")
        }
    }

    @ViewBuilder
    private func avatarHeaderSection(vm: ProfileViewModel, user: User) -> some View {
        VStack(spacing: 16) {
            Group {
                if vm.isEditing {
                    Button {
                        vm.promptAvatarChange()
                    } label: {
                        avatarImage(vm: vm, user: user)
                            .overlay(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    .offset(x: 4, y: 4)
                            }
                    }
                } else {
                    avatarImage(vm: vm, user: user)
                }
            }

            VStack(spacing: 4) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func avatarImage(vm: ProfileViewModel, user: User) -> some View {
        Group {
            if let localImage = vm.selectedAvatarImage {
                localImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                let url: String? = !vm.avatarUrlText.isEmpty ? vm.avatarUrlText : user.avatarURL
                AvatarView(url: url, firstName: user.firstName, lastName: user.lastName, size: 100)
            }
        }
    }

    @ViewBuilder
    private func infoSection(vm: ProfileViewModel, user: User) -> some View {
        VStack(spacing: 0) {
            if vm.isEditing {
                infoRow(icon: "person", label: "Имя") {
                    TextField("Имя", text: Bindable(vm).firstName)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("profile_first_name")
                }

                Divider().padding(.leading, 52)

                infoRow(icon: "person.fill", label: "Фамилия") {
                    TextField("Фамилия", text: Bindable(vm).lastName)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("profile_last_name")
                }
            } else {
                infoRow(icon: "person", label: "Имя") {
                    Text(user.firstName)
                        .foregroundStyle(.secondary)
                }

                Divider().padding(.leading, 52)

                infoRow(icon: "person.fill", label: "Фамилия") {
                    Text(user.lastName)
                        .foregroundStyle(.secondary)
                }
            }

            Divider().padding(.leading, 52)

            infoRow(icon: "envelope", label: "Email") {
                Text(user.email)
                    .foregroundStyle(.secondary)
            }

            if let dob = user.dateOfBirth {
                Divider().padding(.leading, 52)

                infoRow(icon: "calendar", label: "Дата рождения") {
                    Text(dob, style: .date)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .padding(.horizontal, 16)
    }

    private func infoRow<Content: View>(icon: String, label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .frame(width: 22)
                .padding(.leading, 16)

            Text(label)
                .font(.subheadline)

            Spacer()

            content()
                .font(.subheadline)
                .padding(.trailing, 16)
        }
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func actionSection(vm: ProfileViewModel) -> some View {
        VStack(spacing: 0) {
            if vm.isEditing {
                Button {
                    Task { let _ = await vm.updateProfile() }
                } label: {
                    Label("Сохранить изменения", systemImage: "checkmark")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(Color.accentColor)
                }

                Divider()

                Button {
                    vm.cancelEditing()
                } label: {
                    Text("Отмена")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    vm.isEditing = true
                } label: {
                    Label("Редактировать профиль", systemImage: "pencil")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .padding(.horizontal, 16)
    }

    private var logoutSection: some View {
        Button(role: .destructive) {
            showLogoutAlert = true
        } label: {
            Label("Выйти из аккаунта", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.08))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .padding(.horizontal, 16)
        .accessibilityIdentifier("logout_button")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(AuthManager(apiService: MockAPIService(), keychainHelper: MockKeychainHelper()))
    }
}
