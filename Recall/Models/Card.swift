import Foundation

struct CardAttachment: Codable {
    var type: String
    var src: String
    var aspectRatio: Float?
}

struct CardFace: Codable {
    var text: String
    var attachment: CardAttachment?
}

struct Card: Identifiable, Codable {
    var id: String
    var userID: String
    var createdAt: Date
    var front: CardFace
    var back: CardFace
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
        front: CardFace(text: "Front 1"),
        back: CardFace(text: "Back 1"),
        nextReviewAt: Date().addDays(-7), // 1 week ago
        tags: [],
        reviews: []
    ),
    Card(
        id: "2",
        userID: testUser.id,
        createdAt: Date(),
        front: CardFace(text: "Front 2"),
        back: CardFace(text: "Back 2"),
        nextReviewAt: Date().addDays(-1), // yesterday
        tags: [],
        reviews: []
    ),
    Card(
        id: "3",
        userID: testUser.id,
        createdAt: Date(),
        front: CardFace(text: "This is a really long front, really long, really long, really long, really long"),
        back: CardFace(text: "This is a super long back, super long, super long, super long, super long, super long, super long, super long, super long"),
        nextReviewAt: Date().addDays(1).addHours(1), // in 3 days, 1 hour
        tags: [],
        reviews: []
    )
]
