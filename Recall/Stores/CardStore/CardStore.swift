import Foundation
import Combine

struct CardQueryParams {
    var userID: String
    var needsReview: Bool
    var searchText: String
    var tags: Set<String>
    var notTags: Set<String>
}

protocol CardStore {
    func get(id: String, onRecordReceived: @escaping (Card) -> Void) -> AnyCancellable
    func query(_ params: CardQueryParams, onRecordsReceived: @escaping ([Card]) -> Void) -> AnyCancellable
    func create(_ card: Card)
    func update(_ updatedCard: Card)
    func delete(ids: Set<String>)
}

func queryCardArray(cards allCards: [Card], params: CardQueryParams) -> [Card] {
    var cards = allCards
        .filter { card in
            card.userID == params.userID
        }
    if (params.needsReview) {
        let calendar = Calendar.current
        let tomorrow = Date().addDays(1)
        let tomorrowStart = calendar.startOfDay(for: tomorrow)
        cards = cards.filter { card in
            card.nextReviewAt < tomorrowStart
        }
    }
    if (!params.tags.isEmpty) {
        cards = cards.filter { card in
            card.tags.isSuperset(of: params.tags)
        }
    }
    if (!params.notTags.isEmpty) {
        cards = cards.filter { card in
            card.tags.isDisjoint(with: params.notTags)
        }
    }
    if (!params.searchText.isEmpty) {
        cards = cards.filter { card in
            let cardText = "\(card.front.text.lowercased()) \(card.back.text.lowercased())"
            return cardText.contains(params.searchText.lowercased())
        }
    }
    cards.sort { c1, c2 in
        c1.nextReviewAt < c2.nextReviewAt
    }
    return cards
}
