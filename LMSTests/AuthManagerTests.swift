import XCTest
@testable import LMS

@MainActor
final class AuthManagerTests: XCTestCase {
    var sut: AuthManager!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = AuthManager(apiService: mockAPI, keychainHelper: MockKeychainHelper())
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    // MARK: - Login

    func test_login_validCredentials_setsIsAuthenticated() async throws {
        // Given
        let expectedUser = MockData.sampleUser
        mockAPI.stubbedLoginResponse = AuthResponse(token: "token123", user: expectedUser)

        // When
        try await sut.login(email: "ivan@test.com", password: "password123")

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(sut.currentUser?.id, expectedUser.id)
    }

    func test_login_networkError_throwsAndRemainsUnauthenticated() async {
        // Given
        mockAPI.shouldThrowError = .unauthorized

        // When
        do {
            try await sut.login(email: "wrong@test.com", password: "wrong")
            XCTFail("Expected error")
        } catch {
            // Then
            XCTAssertFalse(sut.isAuthenticated)
            XCTAssertNil(sut.currentUser)
        }
    }

    func test_login_savesTokenToKeychain() async throws {
        // Given
        let keychainHelper = MockKeychainHelper()
        sut = AuthManager(apiService: mockAPI, keychainHelper: keychainHelper)
        mockAPI.stubbedLoginResponse = AuthResponse(token: "saved_token", user: MockData.sampleUser)

        // When
        try await sut.login(email: "test@test.com", password: "pass")

        // Then
        XCTAssertEqual(keychainHelper.savedToken, "saved_token")
    }

    // MARK: - Register

    func test_register_success_setsIsAuthenticated() async throws {
        // Given
        let request = RegisterRequest(firstName: "A", lastName: "B", email: "a@b.com", password: "12345678")

        // When
        try await sut.register(request: request)

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
    }

    func test_register_failure_throwsAndRemainsUnauthenticated() async {
        // Given
        mockAPI.shouldThrowError = .conflict("Email exists")

        // When
        do {
            let request = RegisterRequest(firstName: "A", lastName: "B", email: "a@b.com", password: "12345678")
            try await sut.register(request: request)
            XCTFail("Expected error")
        } catch {
            // Then
            XCTAssertFalse(sut.isAuthenticated)
        }
    }

    // MARK: - Logout

    func test_logout_clearsAuthState() async throws {
        // Given
        mockAPI.stubbedLoginResponse = AuthResponse(token: "token", user: MockData.sampleUser)
        try await sut.login(email: "test@test.com", password: "pass")
        XCTAssertTrue(sut.isAuthenticated)

        // When
        sut.logout()

        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
    }

    func test_logout_removesTokenFromKeychain() async throws {
        // Given
        let keychainHelper = MockKeychainHelper()
        sut = AuthManager(apiService: mockAPI, keychainHelper: keychainHelper)
        mockAPI.stubbedLoginResponse = AuthResponse(token: "token", user: MockData.sampleUser)
        try await sut.login(email: "test@test.com", password: "pass")

        // When
        sut.logout()

        // Then
        XCTAssertNil(keychainHelper.savedToken)
    }

    // MARK: - Check Auth

    func test_checkAuth_withToken_setsAuthenticated() async throws {
        // Given
        let keychainHelper = MockKeychainHelper()
        keychainHelper.savedToken = "existing_token"
        mockAPI.stubbedProfile = MockData.sampleUser
        sut = AuthManager(apiService: mockAPI, keychainHelper: keychainHelper)

        // When
        await sut.checkAuth()

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
    }

    func test_checkAuth_withoutToken_remainsUnauthenticated() async {
        // Given
        let keychainHelper = MockKeychainHelper()
        keychainHelper.savedToken = nil
        sut = AuthManager(apiService: mockAPI, keychainHelper: keychainHelper)

        // When
        await sut.checkAuth()

        // Then
        XCTAssertFalse(sut.isAuthenticated)
    }

    func test_checkAuth_withInvalidToken_clearsAuth() async {
        // Given
        let keychainHelper = MockKeychainHelper()
        keychainHelper.savedToken = "expired_token"
        mockAPI.shouldThrowError = .unauthorized
        sut = AuthManager(apiService: mockAPI, keychainHelper: keychainHelper)

        // When
        await sut.checkAuth()

        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(keychainHelper.savedToken)
    }
}

// MockKeychainHelper is in LMS/Services/KeychainHelper.swift
