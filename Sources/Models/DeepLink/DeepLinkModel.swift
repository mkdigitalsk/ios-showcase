import Foundation
import Observation

/// The one link waiting to be routed; a flow that reaches its destination consumes it.
@MainActor
@Observable
final class DeepLinkModel {
    private(set) var pending: DeepLinkDestination?
    private let parser: DeepLinkParser

    init(parser: DeepLinkParser) {
        self.parser = parser
    }

    @discardableResult
    func handle(_ url: URL) -> Bool {
        guard let destination = parser.parse(url) else { return false }
        pending = destination
        return true
    }

    func consume(_ destination: DeepLinkDestination) {
        guard pending == destination else { return }
        pending = nil
    }
}
