import SwiftUI

struct AssignmentTeacherView: View {
    @Environment(\.apiService) private var apiService
    @State private var viewModel: AssignmentTeacherViewModel

    init(assignment: Assignment) {
        _viewModel = State(initialValue: AssignmentTeacherViewModel(assignment: assignment, apiService: APIService.shared))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                infoSection

                filterSection

                submissionsSection

                commentsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .overlay {
            if viewModel.isLoading && viewModel.submissions.isEmpty {
                ProgressView()
            }
        }
        .task {
            viewModel.apiService = apiService
            await viewModel.loadSubmissions()
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let deadline = viewModel.assignment.deadline {
                DeadlineBadge(deadline: deadline)
            }

            if !viewModel.assignment.description.isEmpty {
                Text(viewModel.assignment.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            if let fileUrls = viewModel.assignment.fileUrls, !fileUrls.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Прикреплённые файлы", systemImage: "paperclip")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    ForEach(fileUrls, id: \.self) { url in
                        FileAttachmentView(fileURLString: url)
                    }
                }
            }

            HStack(spacing: 16) {
                statCard(
                    value: "\(viewModel.submittedCount)",
                    label: "Ответов",
                    icon: "tray.fill",
                    color: .blue
                )
                statCard(
                    value: "\(viewModel.submissions.filter { $0.grade != nil }.count)",
                    label: "Оценено",
                    icon: "checkmark.seal.fill",
                    color: .green
                )
                statCard(
                    value: "\(viewModel.submissions.filter { $0.grade == nil }.count)",
                    label: "Ожидают",
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var filterSection: some View {
        Picker("Фильтр", selection: Bindable(viewModel).filter) {
            ForEach(SubmissionFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var submissionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Ответы студентов", systemImage: "person.3")
                .font(.headline)
                .padding(.horizontal, 4)

            if viewModel.filteredSubmissions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        Text("Нет ответов")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(32)
                    Spacer()
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.filteredSubmissions.enumerated()), id: \.element.id) { index, submission in
                        NavigationLink(value: submission) {
                            SubmissionRowView(submission: submission)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

                        if index < viewModel.filteredSubmissions.count - 1 {
                            Divider()
                                .padding(.leading, 68)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
            }
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            CommentsSection(assignmentId: viewModel.assignment.id)
                .padding(20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }
}
