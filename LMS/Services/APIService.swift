import Foundation

final class APIService: APIServiceProtocol {

    static let shared = APIService()

    private let baseURL: String
    private let session: URLSession
    private var token: String?

    init(baseURL: String = APIConfig.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func setToken(_ token: String?) {
        self.token = token
    }

    // MARK: - Auth

    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = ["email": email, "password": password]
        return try await post("/auth/login", body: body)
    }

    func register(request: RegisterRequest) async throws -> AuthResponse {
        let data = try JSONEncoder.lms.encode(request)
        return try await post("/auth/register", bodyData: data)
    }

    // MARK: - Classes

    func getMyClasses() async throws -> [ClassRoom] {
        return try await getPage("/classes")
    }

    func createClass(name: String) async throws -> ClassRoom {
        let body = ["name": name]
        return try await post("/classes", body: body)
    }

    func joinClass(code: String) async throws -> ClassRoom {
        let body = ["code": code]
        return try await post("/classes/join", body: body)
    }

    func deleteClass(id: String) async throws {
        try await delete("/classes/\(id)")
    }

    func updateClass(id: String, name: String) async throws -> ClassRoom {
        let body = ["name": name]
        return try await put("/classes/\(id)", body: body)
    }

    // MARK: - Members

    func getMembers(classId: String) async throws -> [Member] {
        return try await getPage("/classes/\(classId)/members")
    }

    func assignRole(classId: String, userId: String, role: Role) async throws {
        let body = ["role": role.rawValue]
        let _: Member = try await put("/classes/\(classId)/members/\(userId)/role", body: body)
    }

    // MARK: - Assignments

    func getAssignments(classId: String) async throws -> [Assignment] {
        return try await getPage("/classes/\(classId)/assignments")
    }

    func createAssignment(classId: String, title: String, description: String, deadline: Date?) async throws -> Assignment {
        var body: [String: Any] = ["title": title, "description": description]
        if let deadline {
            body["deadline"] = ISO8601DateFormatter().string(from: deadline)
        }
        return try await post("/classes/\(classId)/assignments", body: body)
    }

    // MARK: - Submissions

    func submitAnswer(assignmentId: String, text: String?, fileData: Data?, fileName: String?) async throws -> Submission {
        let boundary = UUID().uuidString
        var request = try makeRequest("/assignments/\(assignmentId)/submissions", method: "POST")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        if let text {
            body.appendMultipartField(named: "answerText", value: text, boundary: boundary)
        }
        if let fileData, let fileName {
            body.appendMultipartFile(named: "file", fileName: fileName, data: fileData, boundary: boundary)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        return try await perform(request)
    }

    func getMySubmission(assignmentId: String) async throws -> Submission? {
        do {
            return try await get("/assignments/\(assignmentId)/submissions/my")
        } catch NetworkError.notFound {
            return nil
        }
    }

    func cancelSubmission(assignmentId: String) async throws {
        try await delete("/assignments/\(assignmentId)/submissions/my")
    }

    func getSubmissions(assignmentId: String) async throws -> [Submission] {
        return try await get("/assignments/\(assignmentId)/submissions")
    }

    func gradeSubmission(submissionId: String, grade: Int) async throws -> Submission {
        let body: [String: Any] = ["grade": grade]
        return try await put("/submissions/\(submissionId)/grade", body: body)
    }

    // MARK: - Comments

    func getComments(assignmentId: String) async throws -> [Comment] {
        return try await getPage("/assignments/\(assignmentId)/comments")
    }

    func addComment(assignmentId: String, text: String) async throws -> Comment {
        let body = ["text": text]
        return try await post("/assignments/\(assignmentId)/comments", body: body)
    }

    // MARK: - Profile

    func getProfile() async throws -> User {
        return try await get("/users/me")
    }

    func updateProfile(request: UpdateProfileRequest) async throws -> User {
        let data = try JSONEncoder.lms.encode(request)
        return try await put("/users/me", bodyData: data)
    }

    // MARK: - Private Helpers

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let request = try makeRequest(path, method: "GET")
        return try await perform(request)
    }

    private func getPage<T: Decodable>(_ path: String) async throws -> [T] {
        let page: PageResponse<T> = try await get(path)
        return page.content
    }

    private func post<T: Decodable>(_ path: String, body: [String: Any]) async throws -> T {
        var request = try makeRequest(path, method: "POST")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await perform(request)
    }

    private func post<T: Decodable>(_ path: String, bodyData: Data) async throws -> T {
        var request = try makeRequest(path, method: "POST")
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await perform(request)
    }

    private func put<T: Decodable>(_ path: String, body: [String: Any]) async throws -> T {
        var request = try makeRequest(path, method: "PUT")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await perform(request)
    }

    private func put<T: Decodable>(_ path: String, bodyData: Data) async throws -> T {
        var request = try makeRequest(path, method: "PUT")
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await perform(request)
    }

    private func delete(_ path: String) async throws {
        let request = try makeRequest(path, method: "DELETE")
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    private func makeRequest(_ path: String, method: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.unknown("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.noConnection
        }
        try validateResponse(response, data: data)
        do {
            return try JSONDecoder.lms.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    private func validateResponse(_ response: URLResponse, data: Data? = nil) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response")
        }
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            let message = Self.parseErrorMessage(from: data) ?? "Доступ запрещён"
            throw NetworkError.forbidden(message)
        case 404:
            throw NetworkError.notFound
        case 409:
            let message = Self.parseErrorMessage(from: data) ?? "Конфликт данных"
            throw NetworkError.conflict(message)
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown("HTTP \(httpResponse.statusCode)")
        }
    }

    private static func parseErrorMessage(from data: Data?) -> String? {
        guard let data else { return nil }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String {
            return message
        }
        return nil
    }
}

// MARK: - Data + Multipart

private extension Data {
    mutating func appendMultipartField(named name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }

    mutating func appendMultipartFile(named name: String, fileName: String, data: Data, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        append(data)
        append("\r\n".data(using: .utf8)!)
    }
}
