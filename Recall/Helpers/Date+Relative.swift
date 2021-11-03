import Foundation

extension Date {
    func addSeconds(_ numSeconds: Int) -> Date {
        return self.addingTimeInterval(Double(numSeconds))
    }
    func addMinutes(_ numMinutes: Int) -> Date {
        return self.addSeconds(numMinutes * 60)
    }
    func addHours(_ numHours: Int) -> Date {
        return self.addMinutes(numHours * 60)
    }
    func addDays(_ numDays: Int) -> Date {
        return self.addHours(numDays * 24)
    }
    func formatRelativeReviewDays() -> String {
        return formatRelativeReviewDays(from: Date())
    }
    func daysFrom(_ from: Date) -> Int {
        let calendar = Calendar.current
        let selfStart = calendar.startOfDay(for: self)
        let fromStart = calendar.startOfDay(for: from)
        return calendar.dateComponents([.day], from: fromStart, to: selfStart).day ?? 0
    }
    func formatRelativeReviewDays(from: Date) -> String {
        if self <= from {
            return "today"
        }
        let daysFromNow = daysFrom(from)
        if daysFromNow <= 0 {
            return "today"
        } else if daysFromNow == 1 {
            return "tomorrow"
        } else {
            return "in \(daysFromNow) days"
        }
    }
}
