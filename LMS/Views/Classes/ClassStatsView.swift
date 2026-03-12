import SwiftUI

struct ClassStatsView: View {
    @State private var viewModel: ClassStatsViewModel

    init(classId: String) {
        _viewModel = State(initialValue: ClassStatsViewModel(classId: classId))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Ошибка загрузки", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Повторить") {
                        Task { await viewModel.loadStats() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let stats = viewModel.stats {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        overviewSection(stats: stats)
                        studentsSection(stats: stats)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .refreshable { await viewModel.loadStats() }
            } else {
                ContentUnavailableView(
                    "Нет данных",
                    systemImage: "chart.bar",
                    description: Text("Не удалось загрузить статистику")
                )
            }
        }
        .navigationTitle("Статистика")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadStats() }
    }

    private func overviewSection(stats: ClassStats) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                statCard(
                    value: "\(stats.totalAssignments)",
                    label: "Заданий",
                    icon: "doc.text.fill",
                    color: .blue
                )
                statCard(
                    value: "\(stats.totalStudents)",
                    label: "Студентов",
                    icon: "person.2.fill",
                    color: .teal
                )
            }
            HStack(spacing: 10) {
                statCard(
                    value: stats.classAverageGrade.map { String(format: "%.1f", $0) } ?? "—",
                    label: "Средняя оценка",
                    icon: "star.fill",
                    color: .orange
                )
                statCard(
                    value: String(format: "%.0f%%", stats.submissionRate),
                    label: "Сдали хотя бы раз",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        .frame(maxWidth: .infinity)
    }

    private func studentsSection(stats: ClassStats) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Успеваемость студентов", systemImage: "chart.bar.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if stats.students.isEmpty {
                Text("Нет студентов в классе")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 1) {
                    ForEach(Array(stats.students.enumerated()), id: \.element.id) { index, student in
                        studentRow(student: student, rank: index + 1, totalAssignments: stats.totalAssignments)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func studentRow(student: StudentStat, rank: Int, totalAssignments: Int) -> some View {
        let nameParts = student.studentName.components(separatedBy: " ")
        let firstName = nameParts.first ?? ""
        let lastName = nameParts.dropFirst().joined(separator: " ")

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                rankBadge(rank: rank, averageGrade: student.averageGrade)

                AvatarView(
                    url: student.avatarUrl,
                    firstName: firstName,
                    lastName: lastName,
                    size: 40
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(lastName.isEmpty ? firstName : lastName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(lastName.isEmpty ? "" : firstName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let avg = student.averageGrade {
                        Text(String(format: "%.0f", avg))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(gradeColor(avg))
                    } else {
                        Text("—")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    submissionProgress(student: student, totalAssignments: totalAssignments)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))

            if rank < 1 {
                Divider().padding(.leading, 80)
            }
            Divider().padding(.leading, 14)
        }
    }

    private func rankBadge(rank: Int, averageGrade: Double?) -> some View {
        let color: Color = {
            switch rank {
            case 1: return .yellow
            case 2: return Color(.systemGray3)
            case 3: return .orange
            default: return .clear
            }
        }()

        return ZStack {
            if rank <= 3 {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 24, height: 24)
                Text("\(rank)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(rank <= 3 ? color : .secondary)
            } else {
                Text("\(rank)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(width: 24)
            }
        }
        .frame(width: 24)
    }

    private func submissionProgress(student: StudentStat, totalAssignments: Int) -> some View {
        HStack(spacing: 4) {
            if student.missedCount > 0 {
                Label("\(student.missedCount)", systemImage: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            Text("\(student.submittedCount)/\(totalAssignments)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func gradeColor(_ grade: Double) -> Color {
        switch grade {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
}

#Preview {
    NavigationStack {
        ClassStatsView(classId: "class-1")
    }
}
