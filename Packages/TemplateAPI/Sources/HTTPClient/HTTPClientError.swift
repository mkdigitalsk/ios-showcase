import Foundation

package enum HTTPClientError: Error, Equatable, Sendable {
    /// Any status outside 2xx, with the body the server sent — the layer above decides what it means.
    case status(code: Int, body: Data)
}
