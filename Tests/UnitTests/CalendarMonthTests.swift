import Foundation
@testable import TemplateIOS
import Testing

struct CalendarMonthTests {
    @Test
    func `a Monday-first grid of September 2026 starts on the 31st of August`() {
        let calendar = Calendar.stub
        let month = CalendarMonth(containing: Date.stubDay, calendar: calendar)

        #expect(month.days.count == 42)
        #expect(calendar.dateComponents([.day, .month], from: month.days[0].date) == DateComponents(month: 8, day: 31))
        #expect(!month.days[0].isInMonth)
        #expect(month.days[1].isInMonth)
        #expect(month.days.filter(\.isInMonth).count == 30)
        #expect(CalendarMonth.weekdaySymbols(calendar: calendar).first == "Mon")
    }

    @Test
    func `a Sunday-first grid starts on the month's own first day when it is a Sunday`() throws {
        var calendar = Calendar.stub
        calendar.firstWeekday = 1
        let november = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 10)))

        let month = CalendarMonth(containing: november, calendar: calendar)

        #expect(calendar.component(.day, from: month.days[0].date) == 1)
        #expect(month.days[0].isInMonth)
        #expect(CalendarMonth.weekdaySymbols(calendar: calendar).first == "Sun")
    }
}
