import Foundation

struct CalendarDay: Equatable, Identifiable, Sendable {
    let date: Date
    let isInMonth: Bool

    var id: Date {
        date
    }
}

/// One month as a six-week grid, padded with the neighbouring months' days, weeks starting on the
/// calendar's first weekday.
struct CalendarMonth: Equatable, Sendable {
    static let weeks = 6
    static let daysPerWeek = 7

    let start: Date
    let days: [CalendarDay]

    init(containing date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month], from: date)
        let start = calendar.date(from: components) ?? calendar.startOfDay(for: date)
        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + Self.daysPerWeek) % Self.daysPerWeek
        let gridStart = calendar.date(byAdding: .day, value: -leading, to: start) ?? start
        self.start = start
        days = (0 ..< Self.weeks * Self.daysPerWeek).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: gridStart) else { return nil }
            return CalendarDay(date: day, isInMonth: calendar.isDate(day, equalTo: start, toGranularity: .month))
        }
    }

    /// The short weekday names in grid order.
    static func weekdaySymbols(calendar: Calendar) -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }
}
