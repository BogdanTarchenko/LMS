import SwiftUI

// MARK: - Teacher: grade a team

struct GradeTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apiService) private var apiService

    let assignmentId: String
    let team: TeamListItem
    var onGraded: (() -> Void)?

    @State private var gradeText = ""
    @State private var comment = ""
    @State private var gradeError: String?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }

                    // Team info
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.15))
                                .frame(width: 48, height: 48)
                            Image(systemName: "person.3.fill")
                                .foregroundStyle(Color.accentColor)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(team.name)
                                .font(.headline)
                            Text("\(team.memberCount) участников")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    gradeSection
                    commentSection
                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Оценить команду")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
            .onAppear {  }
        }
    }

    private var gradeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Оценка (0–100)", systemImage: "star.circle")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Image(systemName: "number")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    TextField("85", text: $gradeText)
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(gradeError != nil ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )

                if let error = gradeError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.leading, 4)
                }
            }
        }
    }

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Комментарий (необязательно)", systemImage: "text.bubble")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            TextEditor(text: $comment)
                .frame(minHeight: 80)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var submitButton: some View {
        LoadingButton(title: "Выставить оценку", isLoading: isLoading) {
            Task { await submit() }
        }
    }

    private func submit() async {
        gradeError = nil
        errorMessage = nil
        guard let grade = Int(gradeText), grade >= 0, grade <= 100 else {
            gradeError = "Оценка должна быть от 0 до 100"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await apiService.createTeamGrade(
                assignmentId: assignmentId,
                teamId: team.id,
                grade: grade,
                comment: comment.isEmpty ? nil : comment
            )
            onGraded?()
            dismiss()
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Teacher: view grades + adjustments

struct TeamGradesView: View {
    @Environment(\.apiService) private var apiService
    @State private var viewModel: TeamGradeViewModel
    @State private var expandedGradeId: String?

    let teams: [TeamListItem]

    init(assignmentId: String, teams: [TeamListItem]) {
        _viewModel = State(initialValue: TeamGradeViewModel(assignmentId: assignmentId))
        self.teams = teams
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let error = viewModel.errorMessage {
                ErrorBanner(message: error)
            }

            if viewModel.isLoading && viewModel.teamGrades.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.teamGrades.isEmpty {
                Text("Оценки ещё не выставлены")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.teamGrades) { grade in
                    teamGradeCard(grade: grade)
                }
            }
        }
        .task {
            viewModel.apiService = apiService
            await viewModel.loadTeamGrades()
        }
    }

    private func teamGradeCard(grade: TeamGrade) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedGradeId = expandedGradeId == grade.id ? nil : grade.id
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(grade.teamName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Text("\(grade.individualGrades.count) участников")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(grade.grade)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)

                    Image(systemName: expandedGradeId == grade.id ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            if expandedGradeId == grade.id {
                Divider().padding(.horizontal, 16)

                if let comment = grade.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                    Divider().padding(.horizontal, 16)
                }

                ForEach(grade.individualGrades) { adj in
                    adjustmentRow(adj: adj, teamGradeId: grade.id)
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func adjustmentRow(adj: IndividualAdjustment, teamGradeId: String) -> some View {
        HStack(spacing: 12) {
            AvatarView(url: nil, firstName: String(adj.studentName.split(separator: " ").first ?? ""), lastName: String(adj.studentName.split(separator: " ").dropFirst().first ?? ""), size: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(adj.studentName)
                    .font(.caption)
                    .fontWeight(.medium)
                if let comment = adj.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(adj.finalGrade)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if adj.adjustment != 0 {
                    Text(adj.adjustment > 0 ? "+\(adj.adjustment)" : "\(adj.adjustment)")
                        .font(.caption2)
                        .foregroundStyle(adj.adjustment > 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Student: my team grade

struct MyTeamGradeView: View {
    @Environment(\.apiService) private var apiService
    @State private var viewModel: MyTeamGradeViewModel

    init(assignmentId: String) {
        _viewModel = State(initialValue: MyTeamGradeViewModel(assignmentId: assignmentId))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let grade = viewModel.myTeamGrade {
                gradeCard(grade: grade)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text("Оценка за командное задание ещё не выставлена")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .task {
            viewModel.apiService = apiService
            await viewModel.load()
        }
    }

    private func gradeCard(grade: MyTeamGrade) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(grade.teamName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Командная оценка")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(grade.myFinalGrade)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                    if grade.myAdjustment != 0 {
                        Text("Команда: \(grade.teamGrade) \(grade.myAdjustment > 0 ? "+" : "")\(grade.myAdjustment)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let comment = grade.comment, !comment.isEmpty {
                Divider()
                Text(comment)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
