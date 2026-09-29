#if DEBUG
import Foundation

extension Calendar {
    /// Gregorian, Monday first, en_GB, Bratislava — what the previews, the snapshots and the date tests pin.
    static var stub: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_GB")
        calendar.timeZone = TimeZone(identifier: "Europe/Bratislava")!
        calendar.firstWeekday = 2
        return calendar
    }
}

extension Date {
    /// 2026-09-16 at midnight in Bratislava.
    static var stubDay: Date {
        Calendar.stub.startOfDay(for: Date(timeIntervalSince1970: 1_789_500_000))
    }
}
#endif
