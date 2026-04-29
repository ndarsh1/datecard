import Foundation

enum AppError: LocalizedError {
    case network(statusCode: Int, message: String?)
    case decoding(Error)
    case unauthorized
    case notFound
    case serverError(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .network(let code, let message):
            return message ?? "Network error (HTTP \(code))"
        case .decoding(let error):
            return "Failed to process response: \(error.localizedDescription)"
        case .unauthorized:
            return "Please sign in again."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let message):
            return message
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
