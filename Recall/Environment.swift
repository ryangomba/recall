import Foundation

class AppEnvironment: ObservableObject {
    var sessionStore: SessionStore
    var cardStore: CardStore

    init(sessionStore: SessionStore, cardStore: CardStore) {
        self.sessionStore = sessionStore
        self.cardStore = cardStore
    }
}

let testSessionStore = SessionStore() // TODO
let testCardStore = MemoryCardStore()
let testAppEnvironment = AppEnvironment(
    sessionStore: testSessionStore,
    cardStore: testCardStore
)

let liveSessionStore = SessionStore()
let liveCardStore = FirestoreCardStore()
let liveAppEnvironment = AppEnvironment(
    sessionStore: liveSessionStore,
    cardStore: liveCardStore
)

let env = liveAppEnvironment
