import Foundation

enum APIConfig {
    static let baseURL = "http://localhost:8080/api/v1"

    /// Resolves a file URL that may be relative (e.g. `/api/v1/files/abc.pdf`)
    /// to a full URL using the server host.
    static func resolveFileURL(_ path: String) -> URL? {
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        guard let base = URL(string: baseURL),
              let scheme = base.scheme,
              let host = base.host else { return nil }
        let port = base.port.map { ":\($0)" } ?? ""
        return URL(string: "\(scheme)://\(host)\(port)\(path)")
    }
}
