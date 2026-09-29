import Foundation

extension NoteSort {
    var text: LocalizedStringResource {
        switch self {
        case .dateDescending: .databaseSortDateNewest
        case .dateAscending: .databaseSortDateOldest
        case .titleAscending: .databaseSortTitleAsc
        case .titleDescending: .databaseSortTitleDesc
        }
    }
}
