import Foundation

class CardService {

    static func createDraft(text: String) {
        return createCard(
            front: CardFace(text: text),
            back: CardFace(text: ""),
            tags: ["draft"],
            reversed: false
        )
    }

    static func createCard(front: String, back: String) {
        return createCard(
            front: CardFace(text: front),
            back: CardFace(text: back),
            tags: [],
            reversed: false
        )
    }

    static func createCard(front: CardFace, back: CardFace, tags: Set<String>, reversed: Bool) {
        var card = Card(
            id: UUID().uuidString,
            userID: env.sessionStore.user!.id,
            createdAt: Date(),
            front: front,
            back: back,
            nextReviewAt: Date(),
            tags: tags,
            reviews: [],
            reversedCardID: nil
        )
        if reversed {
            let reversedCard = generateReversedCard(card)
            card.reversedCardID = reversedCard.id
            env.cardStore.create(reversedCard)
        }
        env.cardStore.create(card)
    }

    static func generateReversedCard(_ card: Card) -> Card {
        return Card(
            id: UUID().uuidString,
            userID: card.userID,
            createdAt: Date(),
            front: card.back,
            back: card.front,
            nextReviewAt: Date(),
            tags: card.tags,
            reviews: [],
            reversedCardID: card.id
        )
    }

    static func reviewCard(card: Card, success: Bool) {
        let review = Review(
            createdAt: Date(),
            result: success
        )
        var updatedCard = card
        updatedCard.reviews = card.reviews + [review]
        updatedCard.nextReviewAt = calculateNextReviewAt(card: updatedCard)
        env.cardStore.update(updatedCard)
    }

    private static func calculateNextReviewAt(card: Card) -> Date {
        if card.reviews.isEmpty {
            return card.createdAt
        }
        let lastReview = card.reviews.last!
        if lastReview.result == false {
            // last review failed, wait a day and retry
            return lastReview.createdAt.addDays(1)
        }
        var failedReviewEncountered = false
        let successfulReviews = card.reviews.reversed().filter { review in
            failedReviewEncountered = failedReviewEncountered || review.result == false
            if failedReviewEncountered {
                return false
            }
            return true
        }
        let numDays: Int
        switch successfulReviews.count {
        case 1:
            numDays = 3
        case 2:
            numDays = 7
        case 3:
            numDays = 14
        case 4:
            numDays = 28
        default:
            numDays = 56
        }
        return lastReview.createdAt.addDays(numDays)
    }

    static func deleteCards(_ ids: Set<String>) {
        env.cardStore.delete(ids: ids)
    }

}
