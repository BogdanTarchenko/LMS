import Foundation

@Observable
final class DeepLinkHandler {
    var pendingJoinCode: String?

    func handle(url: URL) {
        guard url.scheme == "lms",
              url.host == "join",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else { return }

        pendingJoinCode = code
    }

    func consumeCode() -> String? {
        let code = pendingJoinCode
        pendingJoinCode = nil
        return code
    }
}
