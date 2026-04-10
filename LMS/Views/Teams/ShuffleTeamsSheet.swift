import SwiftUI

struct ShuffleTeamsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apiService) private var apiService

    let classId: String
    var onShuffled: (() -> Void)?

    @State private var teamCount = 2
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var previewResult: ShuffleResponse?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let error = errorMessage {
                        ErrorBanner(message: error)
                    }

                    settingsSection

                    if let result = previewResult {
                        previewSection(result)
                    }

                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Перемешать команды")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Настройки", systemImage: "slider.horizontal.3")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                HStack {
                    Label("Количество команд", systemImage: "person.3")
                        .font(.subheadline)
                    Spacer()
                    Stepper("\(teamCount)", value: $teamCount, in: 2...20)
                        .fixedSize()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider().padding(.horizontal, 16)

                HStack {
                    Label("Стратегия", systemImage: "shuffle")
                        .font(.subheadline)
                    Spacer()
                    Text("Случайная")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    @ViewBuilder
    private func previewSection(_ result: ShuffleResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Результат", systemImage: "checkmark.circle")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                HStack {
                    Text("Всего учеников")
                        .font(.subheadline)
                    Spacer()
                    Text("\(result.totalStudents)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.horizontal, 16)

                HStack {
                    Text("Учеников в команде")
                        .font(.subheadline)
                    Spacer()
                    Text("~\(result.studentsPerTeam)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            ForEach(result.teams) { team in
                teamPreviewCard(team: team)
            }
        }
    }

    private func teamPreviewCard(team: Team) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(team.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            FlowLayout(spacing: 6) {
                ForEach(team.members) { member in
                    HStack(spacing: 4) {
                        if member.isLeader {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        Text(member.fullName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            LoadingButton(
                title: previewResult == nil ? "Перемешать" : "Перемешать снова",
                isLoading: isLoading
            ) {
                Task { await shuffle() }
            }

            if previewResult != nil {
                Button {
                    onShuffled?()
                    dismiss()
                } label: {
                    Text("Подтвердить")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private func shuffle() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            previewResult = try await apiService.shuffleTeams(
                classId: classId,
                teamCount: teamCount,
                assignmentId: nil,
                strategy: "RANDOM"
            )
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Simple Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return CGSize(
            width: proposal.width ?? 0,
            height: rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var currentWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentWidth + size.width > maxWidth && !rows.last!.isEmpty {
                rows.append([])
                currentWidth = 0
            }
            rows[rows.count - 1].append(subview)
            currentWidth += size.width + spacing
        }
        return rows
    }
}
