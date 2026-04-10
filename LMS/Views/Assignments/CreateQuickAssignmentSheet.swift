import SwiftUI

struct CreateQuickAssignmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apiService) private var apiService

    let classId: String
    var onCreated: (() -> Void)?

    @State private var title = ""
    @State private var titleError: String?
    @State private var isTeamBased = false
    @State private var teams: [TeamListItem] = []
    @State private var selectedTeamIds: Set<String> = []
    @State private var isLoading = false
    @State private var isLoadingTeams = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }

                    titleSection
                    teamToggleSection

                    if isTeamBased {
                        teamsSection
                    }

                    createButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Быстрое задание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
            .onChange(of: isTeamBased) { _, newValue in
                if newValue && teams.isEmpty {
                    Task { await loadTeams() }
                }
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Задание", systemImage: "bolt.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Image(systemName: "textformat")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    TextField("Например: Спеть «Катюшу» в ансамбле", text: $title)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(titleError != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )

                if let error = titleError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.leading, 4)
                }
            }
        }
    }

    private var teamToggleSection: some View {
        Toggle(isOn: $isTeamBased) {
            Label("Командное задание", systemImage: "person.3")
                .font(.subheadline)
        }
        .tint(.accentColor)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Команды (необязательно)", systemImage: "checklist")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if isLoadingTeams {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if teams.isEmpty {
                Text("Нет существующих команд")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(teams.enumerated()), id: \.element.id) { index, team in
                        teamToggleRow(team: team, isLast: index == teams.count - 1)
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    @ViewBuilder
    private func teamToggleRow(team: TeamListItem, isLast: Bool) -> some View {
        let isSelected = selectedTeamIds.contains(team.id)
        Button {
            if isSelected { selectedTeamIds.remove(team.id) }
            else { selectedTeamIds.insert(team.id) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.3")
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text("\(team.memberCount) уч.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .font(.title3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        if !isLast { Divider().padding(.leading, 52) }
    }

    private var createButton: some View {
        LoadingButton(title: "Создать задание", isLoading: isLoading) {
            Task { await create() }
        }
    }

    private func loadTeams() async {
        isLoadingTeams = true
        defer { isLoadingTeams = false }
        do {
            teams = try await apiService.getTeams(classId: classId)
        } catch {}
    }

    private func create() async {
        titleError = nil
        errorMessage = nil
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            titleError = "Введите название задания"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await apiService.createQuickAssignment(
                classId: classId,
                title: title,
                isTeamBased: isTeamBased,
                teamIds: Array(selectedTeamIds)
            )
            onCreated?()
            dismiss()
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
