import Foundation

@Observable
@MainActor
final class CreateAssignmentViewModel {
    var title = ""
    var description = ""
    var titleError: String?
    var errorMessage: String?
    var isLoading = false

    private let classId: String
    private let apiService: APIServiceProtocol

    init(classId: String, apiService: APIServiceProtocol = APIService.shared) {
        self.classId = classId
        self.apiService = apiService
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
                description: description
            )
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
