import Foundation

struct ClassRoom: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var code: String
    var myRole: Role
    var memberCount: Int
}
