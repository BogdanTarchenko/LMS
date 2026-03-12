import Foundation

@Observable
@MainActor
final class ClassDetailViewModel {
    var classroom: ClassRoom
    var assignments: [Assignment] = []
    var isLoading = false
    var errorMessage: String?

    var canCreateAssignment: Bool {
        classroom.myRole == .owner || classroom.myRole == .teacher
    }

    private let apiService: APIServiceProtocol

    init(classroom: ClassRoom, apiService: APIServiceProtocol = APIService.shared) {
        self.classroom = classroom
        self.apiService = apiService
    }

    func loadAssignments() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            assignments = try await apiService.getAssignments(classId: classroom.id)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteClass() async -> Bool {
        do {
            try await apiService.deleteClass(id: classroom.id)
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func renameClass(to name: String) async -> Bool {
        do {
            let updated = try await apiService.updateClass(id: classroom.id, name: name)
            classroom = updated
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func regenerateCode() async -> Bool {
        do {
            let updated = try await apiService.regenerateCode(id: classroom.id)
            classroom = updated
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
