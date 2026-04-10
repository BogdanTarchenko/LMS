import Foundation

@Observable
@MainActor
final class TeamsViewModel {
    var teams: [TeamListItem] = []
    var isLoading = false
    var errorMessage: String?

    let classId: String
    let myRole: Role
    var apiService: APIServiceProtocol

    var canManageTeams: Bool { myRole == .owner || myRole == .teacher }

    init(classId: String, myRole: Role, apiService: APIServiceProtocol = APIService.shared) {
        self.classId = classId
        self.myRole = myRole
        self.apiService = apiService
    }

    func loadTeams() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            teams = try await apiService.getTeams(classId: classId)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTeam(id: String) async {
        do {
            try await apiService.deleteTeam(classId: classId, teamId: id)
            teams.removeAll { $0.id == id }
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Team Detail

@Observable
@MainActor
final class TeamDetailViewModel {
    var team: Team?
    var isLoading = false
    var errorMessage: String?

    let classId: String
    let teamId: String
    let myRole: Role
    var apiService: APIServiceProtocol

    var canManage: Bool { myRole == .owner || myRole == .teacher }

    init(classId: String, teamId: String, myRole: Role, apiService: APIServiceProtocol = APIService.shared) {
        self.classId = classId
        self.teamId = teamId
        self.myRole = myRole
        self.apiService = apiService
    }

    func loadTeam() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            team = try await apiService.getTeam(classId: classId, teamId: teamId)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeMemeber(userId: String) async {
        do {
            try await apiService.removeTeamMember(classId: classId, teamId: teamId, userId: userId)
            team?.members.removeAll { $0.userId == userId }
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeLeader(userId: String) async {
        do {
            let updated = try await apiService.updateTeam(classId: classId, teamId: teamId, name: nil, leaderUserId: userId)
            team = updated
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(to name: String) async {
        do {
            let updated = try await apiService.updateTeam(classId: classId, teamId: teamId, name: name, leaderUserId: nil)
            team = updated
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
