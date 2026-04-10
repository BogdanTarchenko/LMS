import SwiftUI

struct CreateTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apiService) private var apiService

    let classId: String
    var onCreated: (() -> Void)?

    @State private var name = ""
    @State private var nameError: String?
    @State private var members: [Member] = []
    @State private var selectedMemberIds: Set<String> = []
    @State private var leaderUserId: String?
    @State private var assignments: [Assignment] = []
    @State private var selectedAssignmentId: String? = nil
    @State private var isLoading = false
    @State private var isLoadingMembers = false
    @State private var errorMessage: String?

    private var selectedMembers: [Member] {
        members.filter { selectedMemberIds.contains($0.userId) }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }

                    nameSection
                    assignmentSection
                    membersSection
                    if !selectedMembers.isEmpty {
                        leaderSection
                    }
                    createButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Новая команда")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
            .task {
                isLoadingMembers = true
                async let membersResult = apiService.getMembers(classId: classId)
                async let assignmentsResult = apiService.getAssignments(classId: classId)
                members = (try? await membersResult)?.filter { $0.role == .student } ?? []
                assignments = (try? await assignmentsResult) ?? []
                isLoadingMembers = false
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("Название", icon: "textformat")
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    TextField("Например: Ансамбль А", text: $name)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(nameError != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )

                if let error = nameError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.leading, 4)
                }
            }
        }
    }

    private var assignmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Привязка к заданию", icon: "doc.text")

            VStack(spacing: 0) {
                // Постоянная команда
                Button {
                    selectedAssignmentId = nil
                } label: {
                    HStack {
                        Label("Постоянная команда", systemImage: "infinity")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selectedAssignmentId == nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }

                if !assignments.isEmpty {
                    Divider().padding(.horizontal, 16)

                    ForEach(Array(assignments.enumerated()), id: \.element.id) { index, assignment in
                        Button {
                            selectedAssignmentId = assignment.id
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: assignment.isQuick ? "bolt.fill" : "doc.text.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(assignment.isQuick ? .orange : Color.accentColor)
                                    .frame(width: 20)
                                Text(assignment.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Spacer()
                                if selectedAssignmentId == assignment.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                        }
                        if index < assignments.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Участники", icon: "person.2")

            if isLoadingMembers {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if members.isEmpty {
                Text("В классе нет учеников")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                        memberToggleRow(member: member, isLast: index == members.count - 1)
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var leaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Лидер (необязательно)", icon: "star")

            VStack(spacing: 0) {
                ForEach(Array(selectedMembers.enumerated()), id: \.element.id) { index, member in
                    leaderRadioRow(member: member, isLast: index == selectedMembers.count - 1)
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    @ViewBuilder
    private func memberToggleRow(member: Member, isLast: Bool) -> some View {
        let isSelected = selectedMemberIds.contains(member.userId)
        Button {
            if isSelected {
                selectedMemberIds.remove(member.userId)
                if leaderUserId == member.userId { leaderUserId = nil }
            } else {
                selectedMemberIds.insert(member.userId)
            }
        } label: {
            HStack(spacing: 12) {
                AvatarView(url: nil, firstName: member.firstName, lastName: member.lastName, size: 32)
                Text("\(member.firstName) \(member.lastName)")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .font(.title3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        if !isLast { Divider().padding(.leading, 60) }
    }

    @ViewBuilder
    private func leaderRadioRow(member: Member, isLast: Bool) -> some View {
        let isSelected = leaderUserId == member.userId
        Button {
            leaderUserId = isSelected ? nil : member.userId
        } label: {
            HStack(spacing: 12) {
                AvatarView(url: nil, firstName: member.firstName, lastName: member.lastName, size: 32)
                Text("\(member.firstName) \(member.lastName)")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isSelected ? "star.fill" : "star")
                    .foregroundStyle(isSelected ? .orange : .secondary)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        if !isLast { Divider().padding(.leading, 60) }
    }

    private var createButton: some View {
        LoadingButton(title: "Создать команду", isLoading: isLoading) {
            Task { await createTeam() }
        }
    }

    private func createTeam() async {
        nameError = nil
        errorMessage = nil

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            nameError = "Введите название команды"
            return
        }
        guard !selectedMemberIds.isEmpty else {
            errorMessage = "Выберите хотя бы одного участника"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await apiService.createTeam(
                classId: classId,
                name: name,
                assignmentId: selectedAssignmentId,
                memberUserIds: Array(selectedMemberIds),
                leaderUserId: leaderUserId
            )
            onCreated?()
            dismiss()
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func fieldLabel(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
    }
}
