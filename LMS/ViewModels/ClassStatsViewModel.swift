import Foundation

@Observable
@MainActor
final class ClassStatsViewModel {
    var stats: ClassStats?
    var isLoading = false
    var errorMessage: String?

    private let classId: String
    var apiService: APIServiceProtocol

    init(classId: String, apiService: APIServiceProtocol = APIService.shared) {
        self.classId = classId
        self.apiService = apiService
    }

    func loadStats() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            stats = try await apiService.getClassStats(classId: classId)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
