import Foundation
@testable import TemplateIOS
import Testing

@MainActor
struct CalendarViewModelTests {
    @Test
    func `the demo disables five days after today and refuses a tap on them`() throws {
        let viewModel = CalendarViewModel(today: Date.stubDay, calendar: .stub)
        let disabled = try #require(viewModel.calendar.date(byAdding: .day, value: 3, to: Date.stubDay))

        #expect(viewModel.disabledDays.count == 5)
        #expect(viewModel.isDisabled(disabled))

        viewModel.select(disabled)
        #expect(viewModel.selection == .empty)
    }

    @Test
    func `the month moves both ways and the title follows`() {
        let viewModel = CalendarViewModel(today: Date.stubDay, calendar: .stub)
        #expect(viewModel.monthTitle == "September 2026")

        viewModel.showNextMonth()
        #expect(viewModel.monthTitle == "October 2026")

        viewModel.showPreviousMonth()
        viewModel.showPreviousMonth()
        #expect(viewModel.monthTitle == "August 2026")
    }

    @Test
    func `a day's kind follows the selection`() throws {
        let viewModel = CalendarViewModel(today: Date.stubDay, calendar: .stub)
        let start = try #require(viewModel.calendar.date(byAdding: .day, value: 4, to: Date.stubDay))
        let middle = try #require(viewModel.calendar.date(byAdding: .day, value: 5, to: Date.stubDay))
        let end = try #require(viewModel.calendar.date(byAdding: .day, value: 6, to: Date.stubDay))

        viewModel.select(start)
        #expect(viewModel.kind(of: start) == .start)

        viewModel.select(end)
        #expect(viewModel.kind(of: start) == .start)
        #expect(viewModel.kind(of: middle) == .inRange)
        #expect(viewModel.kind(of: end) == .end)

        viewModel.clear()
        #expect(viewModel.selection == .empty)
        #expect(viewModel.kind(of: start) == .plain)
    }
}
