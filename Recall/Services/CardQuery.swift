import Foundation
import Combine
import SwiftUI

class CardQuery: ObservableObject {
    var store: CardStore
    var params: CardQueryParams {
        didSet {
            runQuery()
        }
    }
    @Published var cards = [Card]()
    @Published var executed = false
    private var foregroundCancellables: Set<AnyCancellable> = []
    private var queryCancellable: Set<AnyCancellable> = []

    init(store: CardStore, params: CardQueryParams) {
        self.store = store
        self.params = params
    }

    func runQuery() {
        queryCancellable.removeAll()
        store.query(params) { cards in
            if self.params.needsReview {
                // Randomize cards for review based on today's date
                class TodayRandomNumberGenerator: RandomNumberGenerator {
                    func next() -> UInt64 {
                        let todayStart = Calendar.current.startOfDay(for: Date())
                        return UInt64(todayStart.timeIntervalSince1970)
                    }
                }
                var generator = TodayRandomNumberGenerator()
                self.cards = cards.shuffled(using: &generator)
            } else {
                self.cards = cards
            }
            if !self.executed {
                self.executed = true
                self.subscribeOnForeground()
            }
        }.store(in: &queryCancellable)
    }

    private func subscribeOnForeground() {
        // TODO: not sure if this is necessary
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { notification in
            self.runQuery()
        }.store(in: &foregroundCancellables)
    }
}
