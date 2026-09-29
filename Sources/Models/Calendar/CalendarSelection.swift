import Foundation

struct DateRange: Equatable, Sendable {
    let start: Date
    let end: Date
}

/// Two taps make a range: the first is the start, the second the end when it lies on or after the
/// start with no disabled day between; any other tap starts over.
enum CalendarSelection: Equatable, Sendable {
    case empty
    case start(Date)
    case range(DateRange)

    var start: Date? {
        switch self {
        case .empty: nil
        case let .start(start): start
        case let .range(range): range.start
        }
    }

    var range: DateRange? {
        if case let .range(range) = self {
            range
        } else {
            nil
        }
    }

    func selecting(_ day: Date, disabledDays: Set<Date>, calendar: Calendar) -> CalendarSelection {
        switch self {
        case .empty, .range:
            return .start(day)
        case let .start(start):
            guard day >= start, !Self.hasDisabledDay(strictlyBetween: start, and: day, in: disabledDays, calendar: calendar) else {
                return .start(day)
            }
            return .range(DateRange(start: start, end: day))
        }
    }

    private static func hasDisabledDay(strictlyBetween start: Date, and end: Date, in disabledDays: Set<Date>, calendar: Calendar) -> Bool {
        guard !disabledDays.isEmpty, var day = calendar.date(byAdding: .day, value: 1, to: start) else { return false }
        while day < end {
            if disabledDays.contains(day) {
                return true
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { return false }
            day = next
        }
        return false
    }
}
