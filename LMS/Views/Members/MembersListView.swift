import SwiftUI

struct MembersListView: View {
    @State private var viewModel: MembersListViewModel

    init(classId: String, myRole: Role) {
        _viewModel = State(initialValue: MembersListViewModel(classId: classId, myRole: myRole))
    }

    var body: some View {
        List {
            if !viewModel.owners.isEmpty {
                Section("Владелец") {
                    ForEach(viewModel.owners) { member in
                        memberRow(member)
                    }
                }
            }

            if !viewModel.teachers.isEmpty {
                Section("Преподаватели") {
                    ForEach(viewModel.teachers) { member in
                        memberRow(member)
                    }
                }
            }

            if !viewModel.students.isEmpty {
                Section("Студенты") {
                    ForEach(viewModel.students) { member in
                        memberRow(member)
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.members.isEmpty {
                ProgressView()
            }
        }
        .refreshable {
            await viewModel.loadMembers()
        }
        .navigationTitle("Участники")
        .task {
            await viewModel.loadMembers()
        }
    }

    @ViewBuilder
    private func memberRow(_ member: Member) -> some View {
        if viewModel.canManageRoles && member.role != .owner {
            MemberRowView(member: member)
                .contextMenu {
                    if member.role == .student {
                        Button("Назначить преподавателем") {
                            Task { await viewModel.assignRole(userId: member.id, role: .teacher) }
                        }
                    } else if member.role == .teacher {
                        Button("Сделать студентом") {
                            Task { await viewModel.assignRole(userId: member.id, role: .student) }
                        }
                    }
                }
        } else {
            MemberRowView(member: member)
        }
    }
}

#Preview {
    NavigationStack {
        MembersListView(classId: "class-1", myRole: .owner)
    }
}
