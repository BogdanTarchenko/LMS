import XCTest
@testable import LMS

@MainActor
final class ClassDetailViewModelTests: XCTestCase {
    var sut: ClassDetailViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = ClassDetailViewModel(classroom: MockData.sampleClasses[0], apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    // MARK: - Load Assignments

    func test_loadAssignments_success_populatesAssignments() async {
        // Given
        mockAPI.stubbedAssignments = MockData.sampleAssignments

        // When
        await sut.loadAssignments()

        // Then
        XCTAssertEqual(sut.assignments.count, MockData.sampleAssignments.count)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadAssignments_empty_returnsEmptyList() async {
        // Given
        mockAPI.stubbedAssignments = []

        // When
        await sut.loadAssignments()

        // Then
        XCTAssertTrue(sut.assignments.isEmpty)
    }

    func test_loadAssignments_networkError_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.loadAssignments()

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Role Checks

    func test_canCreateAssignment_asOwner_returnsTrue() {
        // Given
        sut = ClassDetailViewModel(classroom: MockData.sampleClasses[0], apiService: mockAPI) // owner

        // Then
        XCTAssertTrue(sut.canCreateAssignment)
    }

    func test_canCreateAssignment_asTeacher_returnsTrue() {
        // Given
        sut = ClassDetailViewModel(classroom: MockData.sampleClasses[1], apiService: mockAPI) // teacher

        // Then
        XCTAssertTrue(sut.canCreateAssignment)
    }

    func test_canCreateAssignment_asStudent_returnsFalse() {
        // Given
        sut = ClassDetailViewModel(classroom: MockData.sampleClasses[2], apiService: mockAPI) // student

        // Then
        XCTAssertFalse(sut.canCreateAssignment)
    }

    // MARK: - Delete Class

    func test_deleteClass_success_returnsTrue() async {
        // When
        let result = await sut.deleteClass()

        // Then
        XCTAssertTrue(result)
    }

    func test_deleteClass_failure_returnsFalse() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        let result = await sut.deleteClass()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Rename Class

    func test_renameClass_success_updatesName() async {
        // When
        let result = await sut.renameClass(to: "Новое название")

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.classroom.name, "Новое название")
    }

    func test_renameClass_failure_keepsPreviousName() async {
        // Given
        let originalName = sut.classroom.name
        mockAPI.shouldThrowError = .serverError(500)

        // When
        let result = await sut.renameClass(to: "Другое")

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(sut.classroom.name, originalName)
    }
}
