import Foundation
import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct CalendarScreenViewSnapshotTests {
    @Test
    func empty() {
        assertScreenSnapshots(of: screen(CalendarViewModel(today: Date.stubDay, calendar: .stub)))
    }

    @Test
    func range() throws {
        let viewModel = CalendarViewModel(today: Date.stubDay, calendar: .stub)
        try viewModel.select(#require(viewModel.calendar.date(byAdding: .day, value: 4, to: Date.stubDay)))
        try viewModel.select(#require(viewModel.calendar.date(byAdding: .day, value: 6, to: Date.stubDay)))

        assertScreenSnapshots(of: screen(viewModel), variants: [.light])
    }

    private func screen(_ viewModel: CalendarViewModel) -> some View {
        NavigationStack {
            CalendarScreenView(viewModel: viewModel)
        }
    }
}
