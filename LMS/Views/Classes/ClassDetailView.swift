import SwiftUI

struct ClassDetailView: View {
    @Environment(\.apiService) private var apiService
    @State private var viewModel: ClassDetailViewModel
    @State private var showCreateAssignment = false
    @State private var showSettings = false

    init(classroom: ClassRoom) {
        _viewModel = State(initialValue: ClassDetailViewModel(classroom: classroom, apiService: APIService.shared))
    }

    private var canViewStats: Bool {
        viewModel.classroom.myRole == .owner || viewModel.classroom.myRole == .teacher
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
                        ? "Создайте первое задание для класса"
                        : "Преподаватель ещё не добавил задания"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.assignments) { assignment in
                            NavigationLink(value: assignment) {
                                AssignmentCardView(assignment: assignment, role: viewModel.classroom.myRole)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await viewModel.loadAssignments()
                }
            }
        }
        .navigationTitle(viewModel.classroom.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                NavigationLink(value: "members_\(viewModel.classroom.id)") {
                    Image(systemName: "person.2")
                }

                if canViewStats {
                    NavigationLink(value: "stats_\(viewModel.classroom.id)") {
                        Image(systemName: "chart.bar")
                    }
                }

                if viewModel.canCreateAssignment {
                    Button {
                        showCreateAssignment = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityIdentifier("create_assignment_button")
                }

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
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
            } else if value.hasPrefix("stats_") {
                let classId = String(value.dropFirst("stats_".count))
                ClassStatsView(classId: classId)
            }
        }
        .task {
            viewModel.apiService = apiService
            await viewModel.loadAssignments()
        }
    }
}

#Preview {
    NavigationStack {
        ClassDetailView(classroom: MockData.sampleClasses[0])
    }
}
