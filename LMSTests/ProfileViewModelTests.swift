import XCTest
@testable import LMS

@MainActor
final class ProfileViewModelTests: XCTestCase {
    var sut: ProfileViewModel!
    var mockAPI: MockAPIService!
    var authManager: AuthManager!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        authManager = AuthManager(apiService: mockAPI, keychainHelper: MockKeychainHelper())
        sut = ProfileViewModel(authManager: authManager, apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
        authManager = nil
    }

    // MARK: - Load Profile

    func test_loadProfile_success_populatesUser() async {
        // Given
        mockAPI.stubbedProfile = MockData.sampleUser

        // When
        await sut.loadProfile()

        // Then
        XCTAssertNotNil(sut.user)
        XCTAssertEqual(sut.user?.firstName, MockData.sampleUser.firstName)
    }

    func test_loadProfile_networkError_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.loadProfile()

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Update Profile

    func test_updateProfile_success_updatesUser() async {
        // Given
        mockAPI.stubbedProfile = MockData.sampleUser
        await sut.loadProfile()
        sut.firstName = "Новое"
        sut.lastName = "Имя"

        // When
        let result = await sut.updateProfile()

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.user?.firstName, "Новое")
    }

    func test_updateProfile_failure_setsErrorMessage() async {
        // Given
        sut.firstName = "Test"
        sut.lastName = "User"
        mockAPI.shouldThrowError = .serverError(500)

        // When
        let result = await sut.updateProfile()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Logout

    func test_logout_callsAuthManagerLogout() async throws {
        // Given
        mockAPI.stubbedLoginResponse = AuthResponse(token: "t", user: MockData.sampleUser)
        try await authManager.login(email: "t@t.com", password: "pass")
        XCTAssertTrue(authManager.isAuthenticated)

        // When
        sut.logout()

        // Then
        XCTAssertFalse(authManager.isAuthenticated)
    }

    // MARK: - Editing

    func test_isEditing_defaultFalse() {
        XCTAssertFalse(sut.isEditing)
    }

    func test_toggleEditing_togglesState() {
        // When
        sut.isEditing = true

        // Then
        XCTAssertTrue(sut.isEditing)
    }
}
