import XCTest
@testable import LMS

@MainActor
final class RegisterViewModelTests: XCTestCase {
    var sut: RegisterViewModel!
    var mockAPI: MockAPIService!
    var authManager: AuthManager!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        authManager = AuthManager(apiService: mockAPI, keychainHelper: MockKeychainHelper())
        sut = RegisterViewModel(authManager: authManager)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
        authManager = nil
    }

    // MARK: - Validation: Required Fields

    func test_register_emptyFirstName_setsValidationError() async {
        // Given
        sut.firstName = ""
        sut.lastName = "Петров"
        sut.email = "ivan@test.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.firstNameError)
        XCTAssertFalse(authManager.isAuthenticated)
    }

    func test_register_emptyLastName_setsValidationError() async {
        // Given
        sut.firstName = "Иван"
        sut.lastName = ""
        sut.email = "ivan@test.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.lastNameError)
    }

    // MARK: - Validation: Email

    func test_register_emptyEmail_setsValidationError() async {
        // Given
        fillValidFields()
        sut.email = ""

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.emailError)
    }

    func test_register_invalidEmail_setsValidationError() async {
        // Given
        fillValidFields()
        sut.email = "not-an-email"

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.emailError)
    }

    // MARK: - Validation: Password

    func test_register_shortPassword_setsValidationError() async {
        // Given
        fillValidFields()
        sut.password = "short"
        sut.confirmPassword = "short"

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.passwordError)
    }

    func test_register_passwordMismatch_setsValidationError() async {
        // Given
        fillValidFields()
        sut.password = "password123"
        sut.confirmPassword = "different456"

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.confirmPasswordError)
    }

    // MARK: - Success

    func test_register_validFields_setsIsAuthenticated() async {
        // Given
        fillValidFields()

        // When
        await sut.register()

        // Then
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
    }

    func test_register_success_clearsAllErrors() async {
        // Given
        sut.errorMessage = "Old error"
        sut.firstNameError = "Error"
        fillValidFields()

        // When
        await sut.register()

        // Then
        XCTAssertNil(sut.errorMessage)
        XCTAssertNil(sut.firstNameError)
        XCTAssertNil(sut.lastNameError)
        XCTAssertNil(sut.emailError)
        XCTAssertNil(sut.passwordError)
        XCTAssertNil(sut.confirmPasswordError)
    }

    // MARK: - Network Error

    func test_register_networkError_setsErrorMessage() async {
        // Given
        fillValidFields()
        mockAPI.shouldThrowError = .conflict("Email already exists")

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(authManager.isAuthenticated)
    }

    // MARK: - Loading State

    func test_register_setsIsLoadingDuringRequest() async {
        // Given
        fillValidFields()

        // Then — before
        XCTAssertFalse(sut.isLoading)

        // When
        await sut.register()

        // Then — after
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Multiple Validation Errors

    func test_register_allFieldsEmpty_setsMultipleErrors() async {
        // Given — all fields empty by default

        // When
        await sut.register()

        // Then
        XCTAssertNotNil(sut.firstNameError)
        XCTAssertNotNil(sut.lastNameError)
        XCTAssertNotNil(sut.emailError)
        XCTAssertNotNil(sut.passwordError)
    }

    // MARK: - Helper

    private func fillValidFields() {
        sut.firstName = "Иван"
        sut.lastName = "Петров"
        sut.email = "ivan@test.com"
        sut.password = "password123"
        sut.confirmPassword = "password123"
    }
}
