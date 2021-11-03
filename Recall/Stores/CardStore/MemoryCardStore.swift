import Foundation
import Combine

class MemoryCardStore: CardStore {
    @Published var CARDS = testCards

    func get(id: String, onRecordReceived: @escaping (Card) -> Void) -> AnyCancellable {
        func doGet() {
            let card = CARDS.first { card in
                card.id == id
            }!
            onRecordReceived(card)
        }
        doGet()
        return $CARDS
            .print()
            .receive(on: DispatchQueue.main)
            .sink { cards in
                doGet()
            }
    }

    func query(_ params: CardQueryParams, onRecordsReceived: @escaping ([Card]) -> Void) -> AnyCancellable {
        func doQuery() {
            let cards = queryCardArray(cards: CARDS, params: params)
            onRecordsReceived(cards)
        }
        doQuery()
        return $CARDS
            .print()
            .receive(on: DispatchQueue.main)
            .sink { cards in
                doQuery()
            }
    }

    func create(_ card: Card) {
        CARDS.append(card)
    }

    func update(_ updatedCard: Card) {
        if let index = CARDS.firstIndex(where: { $0.id == updatedCard.id }) {
            CARDS[index] = updatedCard
        }
    }

    func delete(ids: Set<String>) {
        CARDS.removeAll { card in
            ids.contains(card.id)
        }
    }
}
