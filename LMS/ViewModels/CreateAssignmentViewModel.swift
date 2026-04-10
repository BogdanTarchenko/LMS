import Foundation

@Observable
@MainActor
final class CreateAssignmentViewModel {
    var title = ""
    var description = ""
    var hasDeadline = false
    var deadline = Date().addingTimeInterval(7 * 24 * 3600)
    var isTeamBased = false
    var titleError: String?
    var errorMessage: String?
    var isLoading = false

    var selectedFiles: [FileData] = []

    private let classId: String
    var apiService: APIServiceProtocol

    init(classId: String, apiService: APIServiceProtocol = APIService.shared) {
        self.classId = classId
        self.apiService = apiService
    }

    func removeFile(at index: Int) {
        guard index < selectedFiles.count else { return }
        selectedFiles.remove(at: index)
    }

    func createAssignment() async -> Bool {
        titleError = nil
        errorMessage = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            titleError = "Введите заголовок задания"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await apiService.createAssignment(
                classId: classId,
                title: trimmedTitle,
                description: description,
                deadline: hasDeadline ? deadline : nil,
                isTeamBased: isTeamBased,
                files: selectedFiles
            )
            selectedFiles = []
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
