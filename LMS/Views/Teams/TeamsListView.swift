import SwiftUI

struct TeamsListView: View {
    @Environment(\.apiService) private var apiService
    @State private var viewModel: TeamsViewModel
    @State private var showCreateTeam = false
    @State private var showShuffle = false

    init(classId: String, myRole: Role) {
        _viewModel = State(initialValue: TeamsViewModel(classId: classId, myRole: myRole))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.teams.isEmpty {
                ProgressView()
            } else if viewModel.teams.isEmpty {
                EmptyStateView(
                    icon: "person.3",
                    title: "Нет команд",
                    description: viewModel.canManageTeams
                        ? "Создайте команду вручную или перемешайте учеников"
                        : "Преподаватель ещё не создал команды"
                )
            } else {
                List {
                    ForEach(viewModel.teams) { team in
                        ZStack {
                            NavigationLink(value: team) { EmptyView() }.opacity(0)
                            TeamCardView(team: team)
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if viewModel.canManageTeams {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteTeam(id: team.id) }
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.loadTeams() }
            }
        }
        .navigationTitle("Команды")
        .toolbar {
            if viewModel.canManageTeams {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showShuffle = true
                    } label: {
                        Image(systemName: "shuffle")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateTeam = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateTeam) {
            CreateTeamSheet(classId: viewModel.classId) {
                Task { await viewModel.loadTeams() }
            }
        }
        .sheet(isPresented: $showShuffle) {
            ShuffleTeamsSheet(classId: viewModel.classId) {
                Task { await viewModel.loadTeams() }
            }
        }
        .navigationDestination(for: TeamListItem.self) { team in
            TeamDetailView(classId: viewModel.classId, teamId: team.id, myRole: viewModel.myRole)
        }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            viewModel.apiService = apiService
            await viewModel.loadTeams()
        }
    }
}

// MARK: - Team Card

struct TeamCardView: View {
    let team: TeamListItem

    var body: some View {
        HStack(spacing: 12) {
            // Иконка — фиксированный размер
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 44)

            // Основной контент — занимает всё доступное место
            VStack(alignment: .leading, spacing: 5) {
                Text(team.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("\(team.memberCount) \(memberCountLabel(team.memberCount))")
                        .font(.caption)

                    if let leader = team.leaderName {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text(leader)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            typeBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minHeight: 72)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func memberCountLabel(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        if mod100 >= 11 && mod100 <= 14 { return "участников" }
        switch mod10 {
        case 1: return "участник"
        case 2, 3, 4: return "участника"
        default: return "участников"
        }
    }

    private var typeBadge: some View {
        Text(team.isPermanent ? "Постоянная" : "На задание")
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(team.isPermanent
                ? Color.green.opacity(0.15)
                : Color.orange.opacity(0.15))
            .foregroundStyle(team.isPermanent ? .green : .orange)
            .clipShape(Capsule())
    }
}
