import SwiftUI

struct AssignmentTeacherView: View {
    @State private var viewModel: AssignmentTeacherViewModel

    init(assignment: Assignment) {
        _viewModel = State(initialValue: AssignmentTeacherViewModel(assignment: assignment))
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.assignment.description)
                        .font(.body)

                    Text(viewModel.assignment.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("Сдали:")
                            .font(.subheadline)
                        Text("\(viewModel.submittedCount)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }

            Section {
                Picker("Фильтр", selection: Bindable(viewModel).filter) {
                    ForEach(SubmissionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Ответы") {
                if viewModel.filteredSubmissions.isEmpty {
                    Text("Нет ответов")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.filteredSubmissions) { submission in
                        NavigationLink(value: submission) {
                            SubmissionRowView(submission: submission)
                        }
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadSubmissions()
        }
    }
}
