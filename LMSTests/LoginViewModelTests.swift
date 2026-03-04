import XCTest
@testable import LMS

@MainActor
final class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var mockAPI: MockAPIService!
    var authManager: AuthManager!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        authManager = AuthManager(apiService: mockAPI, keychainHelper: MockKeychainHelper())
        sut = LoginViewModel(authManager: authManager)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
        authManager = nil
    }

    // MARK: - Validation

    func test_login_emptyEmail_setsValidationError() async {
        // Given
        sut.email = ""
        sut.password = "password123"

        // When
        await sut.login()

        // Then
        XCTAssertNotNil(sut.emailError)
        XCTAssertFalse(authManager.isAuthenticated)
    }

    func test_login_invalidEmailFormat_setsValidationError() async {
        // Given
        sut.email = "not-an-email"
        sut.password = "password123"

        // When
        await sut.login()

        // Then
        XCTAssertNotNil(sut.emailError)
        XCTAssertFalse(authManager.isAuthenticated)
    }

    func test_login_emptyPassword_setsValidationError() async {
        // Given
        sut.email = "user@test.com"
        sut.password = ""

        // When
        await sut.login()

        // Then
        XCTAssertNotNil(sut.passwordError)
        XCTAssertFalse(authManager.isAuthenticated)
    }

    func test_login_shortPassword_setsValidationError() async {
        // Given
        sut.email = "user@test.com"
        sut.password = "short"

        // When
        await sut.login()

        // Then
        XCTAssertNotNil(sut.passwordError)
    }

    // MARK: - Success

    func test_login_validCredentials_setsIsAuthenticated() async {
        // Given
        sut.email = "user@test.com"
        sut.password = "password123"
        mockAPI.stubbedLoginResponse = AuthResponse(token: "token", user: MockData.sampleUser)

        // When
        await sut.login()

        // Then
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
        XCTAssertNil(sut.emailError)
        XCTAssertNil(sut.passwordError)
    }

    func test_login_validCredentials_clearsErrors() async {
        // Given
        sut.errorMessage = "Previous error"
        sut.email = "user@test.com"
        sut.password = "password123"

        // When
        await sut.login()

        // Then
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Network Error

    func test_login_networkError_setsErrorMessage() async {
        // Given
        sut.email = "user@test.com"
        sut.password = "password123"
        mockAPI.shouldThrowError = .unauthorized

        // When
        await sut.login()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(authManager.isAuthenticated)
    }

    func test_login_serverError_setsErrorMessage() async {
        // Given
        sut.email = "user@test.com"
        sut.password = "password123"
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.login()

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Loading State

    func test_login_setsIsLoadingDuringRequest() async {
        // Given
        sut.email = "user@test.com"
        sut.password = "password123"

        // Then — before
        XCTAssertFalse(sut.isLoading)

        // When
        await sut.login()

        // Then — after
        XCTAssertFalse(sut.isLoading)
    }
}
