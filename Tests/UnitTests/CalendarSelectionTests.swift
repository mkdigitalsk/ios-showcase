import Foundation
@testable import TemplateIOS
import Testing

struct CalendarSelectionTests {
    private let calendar = Calendar.stub
    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: Date.stubDay)!
    }

    @Test
    func `the first tap starts, the second ends`() {
        let started = CalendarSelection.empty.selecting(day(2), disabledDays: [], calendar: calendar)
        #expect(started == .start(day(2)))

        let ended = started.selecting(day(5), disabledDays: [], calendar: calendar)
        #expect(ended == .range(DateRange(start: day(2), end: day(5))))
    }

    @Test
    func `an earlier second tap and a third tap start over`() {
        let started = CalendarSelection.start(day(5))
        #expect(started.selecting(day(2), disabledDays: [], calendar: calendar) == .start(day(2)))

        let range = CalendarSelection.range(DateRange(start: day(2), end: day(5)))
        #expect(range.selecting(day(9), disabledDays: [], calendar: calendar) == .start(day(9)))
    }

    @Test
    func `the same day twice is a single-day range`() {
        let single = CalendarSelection.start(day(3)).selecting(day(3), disabledDays: [], calendar: calendar)
        #expect(single == .range(DateRange(start: day(3), end: day(3))))
    }

    @Test
    func `a disabled day inside the range starts over, on its edge it does not`() {
        let started = CalendarSelection.start(day(2))
        #expect(started.selecting(day(6), disabledDays: [day(4)], calendar: calendar) == .start(day(6)))
        #expect(started.selecting(day(6), disabledDays: [day(6)], calendar: calendar) == .range(DateRange(start: day(2), end: day(6))))
    }
}
