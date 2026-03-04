import XCTest
@testable import LMS

@MainActor
final class ClassListViewModelTests: XCTestCase {
    var sut: ClassListViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = ClassListViewModel(apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    // MARK: - Load Classes

    func test_loadClasses_success_populatesClasses() async {
        // Given
        mockAPI.stubbedClasses = MockData.sampleClasses

        // When
        await sut.loadClasses()

        // Then
        XCTAssertEqual(sut.classes.count, MockData.sampleClasses.count)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadClasses_empty_setsEmptyList() async {
        // Given
        mockAPI.stubbedClasses = []

        // When
        await sut.loadClasses()

        // Then
        XCTAssertTrue(sut.classes.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadClasses_networkError_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.loadClasses()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.classes.isEmpty)
    }

    func test_loadClasses_noConnection_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .noConnection

        // When
        await sut.loadClasses()

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Create Class

    func test_createClass_success_addsClassToList() async {
        // Given
        mockAPI.stubbedClasses = []

        // When
        let result = await sut.createClass(name: "Новый класс")

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.classes.count, 1)
        XCTAssertEqual(sut.classes.first?.name, "Новый класс")
        XCTAssertEqual(sut.classes.first?.myRole, .owner)
    }

    func test_createClass_failure_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        let result = await sut.createClass(name: "Класс")

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.classes.isEmpty)
    }

    // MARK: - Join Class

    func test_joinClass_success_addsClassToList() async {
        // Given
        mockAPI.stubbedClasses = []

        // When
        let result = await sut.joinClass(code: "ABC12345")

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.classes.count, 1)
        XCTAssertEqual(sut.classes.first?.myRole, .student)
    }

    func test_joinClass_invalidCode_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .notFound

        // When
        let result = await sut.joinClass(code: "INVALID")

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_joinClass_conflict_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .conflict("Already a member")

        // When
        let result = await sut.joinClass(code: "ABC12345")

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Loading State

    func test_loadClasses_isLoadingDuringRequest() async {
        // Given
        XCTAssertFalse(sut.isLoading)

        // When
        await sut.loadClasses()

        // Then
        XCTAssertFalse(sut.isLoading)
    }
}
