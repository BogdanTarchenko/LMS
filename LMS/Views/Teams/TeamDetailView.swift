import SwiftUI

struct TeamDetailView: View {
    @Environment(\.apiService) private var apiService
    @State private var viewModel: TeamDetailViewModel
    @State private var showRenameAlert = false
    @State private var newName = ""
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    init(classId: String, teamId: String, myRole: Role) {
        _viewModel = State(initialValue: TeamDetailViewModel(classId: classId, teamId: teamId, myRole: myRole))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.team == nil {
                ProgressView()
            } else if let team = viewModel.team {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if let error = viewModel.errorMessage {
                            ErrorBanner(message: error)
                                .padding(.horizontal, 16)
                        }

                        membersSection(team: team)
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle(viewModel.team?.name ?? "Команда")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.canManage {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        Button {
                            newName = viewModel.team?.name ?? ""
                            showRenameAlert = true
                        } label: {
                            Label("Переименовать", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Удалить команду", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Переименовать команду", isPresented: $showRenameAlert) {
            TextField("Название", text: $newName)
            Button("Отмена", role: .cancel) {}
            Button("Сохранить") {
                Task { await viewModel.rename(to: newName) }
            }
        }
        .confirmationDialog("Удалить команду?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Удалить", role: .destructive) {
                dismiss()
            }
        }
        .task {
            viewModel.apiService = apiService
            await viewModel.loadTeam()
        }
    }

    @ViewBuilder
    private func membersSection(team: Team) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Участники")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(team.members.enumerated()), id: \.element.id) { index, member in
                    memberRow(member: member, team: team, isLast: index == team.members.count - 1)
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func memberRow(member: TeamMember, team: Team, isLast: Bool) -> some View {
        HStack(spacing: 12) {
            AvatarView(url: nil, firstName: member.firstName, lastName: member.lastName, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.fullName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if member.isLeader {
                    Label("Лидер", systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            if viewModel.canManage {
                Menu {
                    if !member.isLeader {
                        Button {
                            Task { await viewModel.makeLeader(userId: member.userId) }
                        } label: {
                            Label("Назначить лидером", systemImage: "star")
                        }
                    }
                    Button(role: .destructive) {
                        Task { await viewModel.removeMemeber(userId: member.userId) }
                    } label: {
                        Label("Удалить из команды", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)

        if !isLast {
            Divider()
                .padding(.leading, 64)
        }
    }
}
