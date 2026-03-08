import Foundation

@Observable
@MainActor
final class MembersListViewModel {
    var members: [Member] = []
    var isLoading = false
    var errorMessage: String?

    let classId: String
    let myRole: Role

    var canManageRoles: Bool { myRole == .owner }

    var owners: [Member] { members.filter { $0.role == .owner } }
    var teachers: [Member] { members.filter { $0.role == .teacher } }
    var students: [Member] { members.filter { $0.role == .student } }

    private let apiService: APIServiceProtocol

    init(classId: String, myRole: Role, apiService: APIServiceProtocol = APIService.shared) {
        self.classId = classId
        self.myRole = myRole
        self.apiService = apiService
    }

    func loadMembers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            members = try await apiService.getMembers(classId: classId)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func assignRole(userId: String, role: Role) async {
        errorMessage = nil
        do {
            try await apiService.assignRole(classId: classId, userId: userId, role: role)
            await loadMembers()
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
