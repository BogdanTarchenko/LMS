import Foundation

@Observable
@MainActor
final class ClassListViewModel {
    var classes: [ClassRoom] = []
    var isLoading = false
    var errorMessage: String?

    var apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func loadClasses() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            classes = try await apiService.getMyClasses()
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func createClass(name: String) async -> Bool {
        errorMessage = nil
        do {
            let newClass = try await apiService.createClass(name: name)
            classes.insert(newClass, at: 0)
            return true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func joinClass(code: String) async -> Bool {
        errorMessage = nil
        do {
            let joined = try await apiService.joinClass(code: code)
            classes.insert(joined, at: 0)
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
