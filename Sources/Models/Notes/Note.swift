import Foundation

struct Note: Equatable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let content: String
    let createdAt: Date
}

enum NoteSort: CaseIterable, Sendable {
    case dateDescending
    case dateAscending
    case titleAscending
    case titleDescending
}

extension [Note] {
    /// The filter and order the stub applies in memory — the live store asks SwiftData for the same.
    func matching(_ query: String, sortedBy sort: NoteSort) -> [Note] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = trimmed.isEmpty ? self : filter {
            $0.title.localizedStandardContains(trimmed) || $0.content.localizedStandardContains(trimmed)
        }
        return switch sort {
        case .dateDescending: filtered.sorted { $0.createdAt > $1.createdAt }
        case .dateAscending: filtered.sorted { $0.createdAt < $1.createdAt }
        case .titleAscending: filtered.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        case .titleDescending: filtered.sorted { $0.title.localizedStandardCompare($1.title) == .orderedDescending }
        }
    }
}
