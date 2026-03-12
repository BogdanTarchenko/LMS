import SwiftUI

struct MembersListView: View {
    @State private var viewModel: MembersListViewModel

    init(classId: String, myRole: Role) {
        _viewModel = State(initialValue: MembersListViewModel(classId: classId, myRole: myRole))
    }

    var body: some View {
        List {
            if !viewModel.owners.isEmpty {
                Section {
                    ForEach(viewModel.owners) { member in
                        memberRow(member)
                    }
                } header: {
                    sectionHeader("Владелец", icon: "crown.fill", color: .purple)
                }
            }

            if !viewModel.teachers.isEmpty {
                Section {
                    ForEach(viewModel.teachers) { member in
                        memberRow(member)
                    }
                } header: {
                    sectionHeader("Преподаватели", icon: "graduationcap.fill", color: .blue)
                }
            }

            if !viewModel.students.isEmpty {
                Section {
                    ForEach(viewModel.students) { member in
                        memberRow(member)
                    }
                } header: {
                    sectionHeader("Студенты", icon: "person.2.fill", color: .teal)
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
    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        Label(title, systemImage: icon)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .textCase(nil)
    }

    @ViewBuilder
    private func memberRow(_ member: Member) -> some View {
        if viewModel.canManageRoles && member.role != .owner {
            MemberRowView(member: member)
                .contextMenu {
                    if member.role == .student {
                        Button {
                            Task { await viewModel.assignRole(userId: member.id, role: .teacher) }
                        } label: {
                            Label("Назначить преподавателем", systemImage: "graduationcap")
                        }
                    } else if member.role == .teacher {
                        Button {
                            Task { await viewModel.assignRole(userId: member.id, role: .student) }
                        } label: {
                            Label("Сделать студентом", systemImage: "person")
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        Task { await viewModel.removeMember(userId: member.id) }
                    } label: {
                        Label("Удалить из класса", systemImage: "person.badge.minus")
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task { await viewModel.removeMember(userId: member.id) }
                    } label: {
                        Label("Удалить", systemImage: "person.badge.minus")
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
