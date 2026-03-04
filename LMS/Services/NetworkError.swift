import Foundation

enum NetworkError: LocalizedError, Equatable {
    case unauthorized
    case notFound
    case noConnection
    case serverError(Int)
    case conflict(String)
    case decodingError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Неавторизован. Войдите в систему."
        case .notFound:
            return "Ресурс не найден."
        case .noConnection:
            return "Нет подключения к сети."
        case .serverError(let code):
            return "Ошибка сервера (\(code))."
        case .conflict(let message):
            return message
        case .decodingError:
            return "Ошибка обработки данных."
        case .unknown(let message):
            return message
        }
    }
}
