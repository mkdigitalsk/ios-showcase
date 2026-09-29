import Foundation

extension Error {
    /// A dismissed screen cancels its task; that is never a failure to show.
    var isCancellation: Bool {
        if self is CancellationError {
            return true
        }
        if let urlError = self as? URLError, urlError.code == .cancelled {
            return true
        }
        return false
    }
}
