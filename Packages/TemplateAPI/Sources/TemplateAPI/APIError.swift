import Foundation
import HTTPClient

/// Every failure a client throws — a status the server sent, a transport that failed, a body that
/// did not decode. Cancellation is not here: a cancelled request rethrows `CancellationError`.
public enum APIError: Error, Equatable, Sendable {
    case unauthorized
    case notFound
    case conflict
    case preconditionFailed(current: NoteResponse)
    case status(Int, detail: String?)
    case offline
    case transport(String)
    case decoding(String)
}

extension APIError {
    static func map(_ error: any Error, decoder: JSONDecoder) -> any Error {
        switch error {
        case is CancellationError:
            error
        case let urlError as URLError where urlError.code == .cancelled:
            CancellationError()
        case let urlError as URLError:
            Self.offlineCodes.contains(urlError.code) ? APIError.offline : .transport(urlError.localizedDescription)
        case let HTTPClientError.status(code, body):
            status(code, body: body, decoder: decoder)
        case let decoding as DecodingError:
            APIError.decoding(String(describing: decoding))
        default:
            APIError.transport(String(describing: error))
        }
    }

    private static let offlineCodes: Set<URLError.Code> = [
        .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .timedOut,
    ]

    private static func status(_ code: Int, body: Data, decoder: JSONDecoder) -> APIError {
        switch code {
        case 401: .unauthorized
        case 404: .notFound
        case 409: .conflict
        case 412:
            if let current = try? decoder.decode(NoteResponse.self, from: body) {
                .preconditionFailed(current: current)
            } else {
                .status(code, detail: ProblemDetails.detail(in: body, decoder: decoder))
            }
        default: .status(code, detail: ProblemDetails.detail(in: body, decoder: decoder))
        }
    }
}

/// The error body the server sends — RFC 9457 problem details, or a bare `message`.
private struct ProblemDetails: Decodable {
    let title: String?
    let detail: String?
    let message: String?

    static func detail(in body: Data, decoder: JSONDecoder) -> String? {
        guard let problem = try? decoder.decode(ProblemDetails.self, from: body) else {
            let text = String(decoding: body, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? nil : text
        }
        return problem.detail ?? problem.message ?? problem.title
    }
}
