import XCTest
@testable import LMS

@MainActor
final class MembersListViewModelTests: XCTestCase {
    var sut: MembersListViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = MembersListViewModel(classId: "class-1", myRole: .owner, apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    // MARK: - Load Members

    func test_loadMembers_success_populatesMembers() async {
        // Given
        mockAPI.stubbedMembers = MockData.sampleMembers

        // When
        await sut.loadMembers()

        // Then
        XCTAssertEqual(sut.members.count, MockData.sampleMembers.count)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadMembers_networkError_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.loadMembers()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.members.isEmpty)
    }

    // MARK: - Grouped Members

    func test_owners_filtersCorrectly() async {
        // Given
        mockAPI.stubbedMembers = MockData.sampleMembers
        await sut.loadMembers()

        // Then
        XCTAssertEqual(sut.owners.count, 1)
        XCTAssertTrue(sut.owners.allSatisfy { $0.role == .owner })
    }

    func test_teachers_filtersCorrectly() async {
        // Given
        mockAPI.stubbedMembers = MockData.sampleMembers
        await sut.loadMembers()

        // Then
        XCTAssertEqual(sut.teachers.count, 1)
        XCTAssertTrue(sut.teachers.allSatisfy { $0.role == .teacher })
    }

    func test_students_filtersCorrectly() async {
        // Given
        mockAPI.stubbedMembers = MockData.sampleMembers
        await sut.loadMembers()

        // Then
        XCTAssertEqual(sut.students.count, 1)
        XCTAssertTrue(sut.students.allSatisfy { $0.role == .student })
    }

    // MARK: - Assign Role

    func test_assignRole_success_reloadsMembers() async {
        // Given
        mockAPI.stubbedMembers = MockData.sampleMembers

        // When
        await sut.assignRole(userId: "user-3", role: .teacher)

        // Then
        XCTAssertNil(sut.errorMessage)
    }

    func test_assignRole_failure_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.assignRole(userId: "user-3", role: .teacher)

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Can Manage Roles

    func test_canManageRoles_asOwner_returnsTrue() {
        // Given
        sut = MembersListViewModel(classId: "c1", myRole: .owner, apiService: mockAPI)

        // Then
        XCTAssertTrue(sut.canManageRoles)
    }

    func test_canManageRoles_asTeacher_returnsFalse() {
        // Given
        sut = MembersListViewModel(classId: "c1", myRole: .teacher, apiService: mockAPI)

        // Then
        XCTAssertFalse(sut.canManageRoles)
    }

    func test_canManageRoles_asStudent_returnsFalse() {
        // Given
        sut = MembersListViewModel(classId: "c1", myRole: .student, apiService: mockAPI)

        // Then
        XCTAssertFalse(sut.canManageRoles)
    }
}
