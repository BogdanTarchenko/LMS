import XCTest
@testable import LMS

// MARK: - CreateAssignmentViewModel

@MainActor
final class CreateAssignmentViewModelTests: XCTestCase {
    var sut: CreateAssignmentViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = CreateAssignmentViewModel(classId: "class-1", apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    func test_create_emptyTitle_setsValidationError() async {
        // Given
        sut.title = ""
        sut.description = "Описание"

        // When
        let result = await sut.createAssignment()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.titleError)
    }

    func test_create_validTitle_returnsTrue() async {
        // Given
        sut.title = "Домашнее задание"
        sut.description = "Решить задачи"

        // When
        let result = await sut.createAssignment()

        // Then
        XCTAssertTrue(result)
        XCTAssertNil(sut.titleError)
        XCTAssertNil(sut.errorMessage)
    }

    func test_create_networkError_setsErrorMessage() async {
        // Given
        sut.title = "Задание"
        mockAPI.shouldThrowError = .serverError(500)

        // When
        let result = await sut.createAssignment()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_create_setsIsLoadingDuringRequest() async {
        // Given
        sut.title = "Задание"
        XCTAssertFalse(sut.isLoading)

        // When
        let _ = await sut.createAssignment()

        // Then
        XCTAssertFalse(sut.isLoading)
    }
}

// MARK: - AssignmentStudentViewModel

@MainActor
final class AssignmentStudentViewModelTests: XCTestCase {
    var sut: AssignmentStudentViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = AssignmentStudentViewModel(assignment: MockData.sampleAssignments[0], apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    func test_submitAnswer_success_updatesStatus() async {
        // Given
        sut.answerText = "Мой ответ"

        // When
        await sut.submitAnswer()

        // Then
        XCTAssertNotNil(sut.submission)
        XCTAssertNil(sut.errorMessage)
    }

    func test_submitAnswer_emptyText_setsValidationError() async {
        // Given
        sut.answerText = ""

        // When
        await sut.submitAnswer()

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_submitAnswer_networkError_setsErrorMessage() async {
        // Given
        sut.answerText = "Ответ"
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.submitAnswer()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.submission)
    }

    func test_hasSubmitted_withSubmission_returnsTrue() {
        // Given
        sut.submission = MockData.sampleSubmissions[0]

        // Then
        XCTAssertTrue(sut.hasSubmitted)
    }

    func test_hasSubmitted_withoutSubmission_returnsFalse() {
        // Then
        XCTAssertFalse(sut.hasSubmitted)
    }
}

// MARK: - AssignmentTeacherViewModel

@MainActor
final class AssignmentTeacherViewModelTests: XCTestCase {
    var sut: AssignmentTeacherViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = AssignmentTeacherViewModel(assignment: MockData.sampleAssignments[0], apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    func test_loadSubmissions_success_populatesSubmissions() async {
        // Given
        mockAPI.stubbedSubmissions = MockData.sampleSubmissions

        // When
        await sut.loadSubmissions()

        // Then
        XCTAssertEqual(sut.submissions.count, MockData.sampleSubmissions.count)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadSubmissions_networkError_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.loadSubmissions()

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_submittedCount_returnsCorrectCount() async {
        // Given
        mockAPI.stubbedSubmissions = MockData.sampleSubmissions
        await sut.loadSubmissions()

        // Then
        XCTAssertEqual(sut.submittedCount, MockData.sampleSubmissions.count)
    }

    func test_filteredSubmissions_all_returnsAll() async {
        // Given
        mockAPI.stubbedSubmissions = MockData.sampleSubmissions
        await sut.loadSubmissions()
        sut.filter = .all

        // Then
        XCTAssertEqual(sut.filteredSubmissions.count, MockData.sampleSubmissions.count)
    }

    func test_filteredSubmissions_graded_returnsOnlyGraded() async {
        // Given
        mockAPI.stubbedSubmissions = MockData.sampleSubmissions
        await sut.loadSubmissions()
        sut.filter = .graded

        // Then
        XCTAssertTrue(sut.filteredSubmissions.allSatisfy { $0.grade != nil })
    }

    func test_filteredSubmissions_notGraded_returnsOnlyNotGraded() async {
        // Given
        mockAPI.stubbedSubmissions = MockData.sampleSubmissions
        await sut.loadSubmissions()
        sut.filter = .notGraded

        // Then
        XCTAssertTrue(sut.filteredSubmissions.allSatisfy { $0.grade == nil })
    }
}

// MARK: - SubmissionDetailViewModel

@MainActor
final class SubmissionDetailViewModelTests: XCTestCase {
    var sut: SubmissionDetailViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = SubmissionDetailViewModel(submission: MockData.sampleSubmissions[0], apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    func test_gradeSubmission_validGrade_updatesSubmission() async {
        // Given
        sut.gradeText = "95"

        // When
        let result = await sut.gradeSubmission()

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.submission.grade, 95)
        XCTAssertNil(sut.errorMessage)
    }

    func test_gradeSubmission_invalidGrade_setsError() async {
        // Given
        sut.gradeText = "abc"

        // When
        let result = await sut.gradeSubmission()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.gradeError)
    }

    func test_gradeSubmission_outOfRange_setsError() async {
        // Given
        sut.gradeText = "150"

        // When
        let result = await sut.gradeSubmission()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.gradeError)
    }

    func test_gradeSubmission_negativeValue_setsError() async {
        // Given
        sut.gradeText = "-5"

        // When
        let result = await sut.gradeSubmission()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.gradeError)
    }

    func test_gradeSubmission_networkError_setsErrorMessage() async {
        // Given
        sut.gradeText = "85"
        mockAPI.shouldThrowError = .serverError(500)

        // When
        let result = await sut.gradeSubmission()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }
}
