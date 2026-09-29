import Foundation
import Observation

/// The range picker's own state: the month on screen, the selection, the days the demo disables.
@MainActor
@Observable
final class CalendarViewModel {
    enum DayKind: Equatable {
        case plain
        case start
        case end
        case inRange
        case single
    }

    private static let disabledOffsets = [3, 7, 8, 12, 15]

    let calendar: Calendar
    let today: Date
    let disabledDays: Set<Date>
    private(set) var month: CalendarMonth
    private(set) var selection = CalendarSelection.empty

    init(today: Date = Date(), calendar: Calendar = .current) {
        self.calendar = calendar
        self.today = calendar.startOfDay(for: today)
        disabledDays = Set(Self.disabledOffsets.compactMap { calendar.date(byAdding: .day, value: $0, to: calendar.startOfDay(for: today)) })
        month = CalendarMonth(containing: today, calendar: calendar)
    }

    var monthTitle: String {
        month.start.formatted(Date.FormatStyle(locale: calendar.locale ?? .current, calendar: calendar, timeZone: calendar.timeZone).month(.wide).year())
    }

    var weekdaySymbols: [String] {
        CalendarMonth.weekdaySymbols(calendar: calendar)
    }

    func select(_ day: Date) {
        guard !isDisabled(day) else { return }
        selection = selection.selecting(day, disabledDays: disabledDays, calendar: calendar)
    }

    func clear() {
        selection = .empty
    }

    func showPreviousMonth() {
        move(by: -1)
    }

    func showNextMonth() {
        move(by: 1)
    }

    func isDisabled(_ day: Date) -> Bool {
        disabledDays.contains(day)
    }

    func isToday(_ day: Date) -> Bool {
        day == today
    }

    func dayNumber(_ day: Date) -> Int {
        calendar.component(.day, from: day)
    }

    func kind(of day: Date) -> DayKind {
        switch selection {
        case .empty:
            return .plain
        case let .start(start):
            return day == start ? .start : .plain
        case let .range(range):
            if range.start == range.end, day == range.start {
                return .single
            }
            if day == range.start {
                return .start
            }
            if day == range.end {
                return .end
            }
            return day > range.start && day < range.end ? .inRange : .plain
        }
    }

    func format(_ day: Date) -> String {
        day.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: calendar.locale ?? .current, calendar: calendar, timeZone: calendar.timeZone))
    }

    private func move(by months: Int) {
        guard let next = calendar.date(byAdding: .month, value: months, to: month.start) else { return }
        month = CalendarMonth(containing: next, calendar: calendar)
    }
}
