import XCTest
@testable import LMS

@MainActor
final class CommentsViewModelTests: XCTestCase {
    var sut: CommentsViewModel!
    var mockAPI: MockAPIService!

    override func setUp() async throws {
        mockAPI = MockAPIService()
        sut = CommentsViewModel(assignmentId: "assign-1", apiService: mockAPI)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPI = nil
    }

    // MARK: - Load Comments

    func test_loadComments_success_populatesComments() async {
        // Given
        mockAPI.stubbedComments = MockData.sampleComments

        // When
        await sut.loadComments()

        // Then
        XCTAssertEqual(sut.comments.count, MockData.sampleComments.count)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadComments_networkError_setsErrorMessage() async {
        // Given
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.loadComments()

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Add Comment

    func test_addComment_success_addsToList() async {
        // Given
        sut.newCommentText = "Новый комментарий"

        // When
        await sut.addComment()

        // Then
        XCTAssertEqual(sut.comments.count, 1)
        XCTAssertEqual(sut.comments.first?.text, "Новый комментарий")
        XCTAssertTrue(sut.newCommentText.isEmpty)
    }

    func test_addComment_emptyText_doesNothing() async {
        // Given
        sut.newCommentText = ""

        // When
        await sut.addComment()

        // Then
        XCTAssertTrue(sut.comments.isEmpty)
    }

    func test_addComment_whitespaceOnly_doesNothing() async {
        // Given
        sut.newCommentText = "   "

        // When
        await sut.addComment()

        // Then
        XCTAssertTrue(sut.comments.isEmpty)
    }

    func test_addComment_networkError_setsErrorMessage() async {
        // Given
        sut.newCommentText = "Комментарий"
        mockAPI.shouldThrowError = .serverError(500)

        // When
        await sut.addComment()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.comments.isEmpty)
    }

    func test_addComment_success_clearsTextField() async {
        // Given
        sut.newCommentText = "Тест"

        // When
        await sut.addComment()

        // Then
        XCTAssertTrue(sut.newCommentText.isEmpty)
    }
}
