import Foundation

struct Card: Identifiable, Codable {
    var id: String
    var userID: String
    var createdAt: Date
    var front: String
    var back: String
    var nextReviewAt: Date
    var tags: Set<String>
    var reviews: [Review]
    var reversedCardID: String?
}

let testCards = [
    Card(
        id: "1",
        userID: testUser.id,
        createdAt: Date(),
        front: "Front 1",
        back: "Back 1",
        nextReviewAt: Date().addDays(-7), // 1 week ago
        tags: [],
        reviews: []
    ),
    Card(
        id: "2",
        userID: testUser.id,
        createdAt: Date(),
        front: "Front 2",
        back: "Back 2",
        nextReviewAt: Date().addDays(-1), // yesterday
        tags: [],
        reviews: []
    ),
    Card(
        id: "3",
        userID: testUser.id,
        createdAt: Date(),
        front: "This is a really long front, really long, really long, really long, really long",
        back: "This is a super long back, super long, super long, super long, super long, super long, super long, super long, super long",
        nextReviewAt: Date().addDays(1).addHours(1), // in 3 days, 1 hour
        tags: [],
        reviews: []
    )
]
