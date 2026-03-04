import Foundation

enum Role: String, Codable, Hashable {
    case owner = "OWNER"
    case teacher = "TEACHER"
    case student = "STUDENT"
}
