import SwiftUI

struct ClassDetailView: View {
    @State private var viewModel: ClassDetailViewModel
    @State private var showCreateAssignment = false
    @State private var showSettings = false

    init(classroom: ClassRoom) {
        _viewModel = State(initialValue: ClassDetailViewModel(classroom: classroom))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.assignments.isEmpty {
                ProgressView()
            } else if viewModel.assignments.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "Нет заданий",
                    description: viewModel.canCreateAssignment
                        ? "Создайте первое задание"
                        : "Преподаватель ещё не добавил задания"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.assignments) { assignment in
                            NavigationLink(value: assignment) {
                                AssignmentCardView(assignment: assignment)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.loadAssignments()
                }
            }
        }
        .navigationTitle(viewModel.classroom.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }

                NavigationLink(value: "members_\(viewModel.classroom.id)") {
                    Image(systemName: "person.2")
                }

                if viewModel.canCreateAssignment {
                    Button {
                        showCreateAssignment = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("create_assignment_button")
                }
            }
        }
        .sheet(isPresented: $showCreateAssignment) {
            CreateAssignmentView(classId: viewModel.classroom.id) {
                Task { await viewModel.loadAssignments() }
            }
        }
        .sheet(isPresented: $showSettings) {
            ClassSettingsView(viewModel: viewModel)
        }
        .navigationDestination(for: Assignment.self) { assignment in
            AssignmentDetailView(assignment: assignment, role: viewModel.classroom.myRole)
        }
        .navigationDestination(for: String.self) { value in
            if value.hasPrefix("members_") {
                let classId = String(value.dropFirst("members_".count))
                MembersListView(classId: classId, myRole: viewModel.classroom.myRole)
            }
        }
        .task {
            await viewModel.loadAssignments()
        }
    }
}

#Preview {
    NavigationStack {
        ClassDetailView(classroom: MockData.sampleClasses[0])
    }
}
