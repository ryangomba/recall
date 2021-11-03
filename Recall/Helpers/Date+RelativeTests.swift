import XCTest

@testable import Recall

class DateRelativeTests: XCTestCase {
    func formatRelativeReviewDays() {
        let now = try! Date("2021-11-15T23:27:17+0000", strategy: .iso8601) // 3:27pm PT
        XCTAssertEqual(now.formatRelativeReviewDays(from: now), "today")
        XCTAssertEqual(now.addHours(1).formatRelativeReviewDays(from: now), "today") // 4:27pm
        XCTAssertEqual(now.addHours(8).formatRelativeReviewDays(from: now), "today") // 11:27pm
        XCTAssertEqual(now.addHours(9).formatRelativeReviewDays(from: now), "tomorrow") // 12:27am
        XCTAssertEqual(now.addDays(2).formatRelativeReviewDays(from: now), "in 2 days") // 3:27pm in 2 days
        XCTAssertEqual(now.addHours(-1).formatRelativeReviewDays(from: now), "today") // 2:27pm
    }
}
