import Foundation

struct FileData: Identifiable {
    let id = UUID()
    let data: Data
    let fileName: String
    let mimeType: String
}
