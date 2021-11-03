import UIKit
import Combine
import UserNotifications

class BadgeManager {
    private var cardQuery = CardQuery(store: env.cardStore, params: CardQueryParams(userID: env.sessionStore.user?.id ?? "", needsReview: true, searchText: "", tags: [], notTags: ["draft"]))
    private var cancellables: Set<AnyCancellable> = []

    func start() {
        if !cancellables.isEmpty {
            return
        }

        env.sessionStore.$user.sink { user in
            self.cardQuery.params.userID = user?.id ?? ""
        }.store(in: &cancellables)

        cardQuery.$cards.map { cards in
            cards.count
        }
        .sink { cardCount in
            self.updateBadge(cardCount)
        }.store(in: &cancellables)

        refresh()

        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification).sink { notification in
            self.updateBadge(self.cardQuery.cards.count)
        }.store(in: &cancellables)
    }

    func refresh() {
        cardQuery.runQuery()
    }

    private func updateBadge(_ cardCount: Int) {
        let badgeAppIcon = UserDefaults.standard.bool(forKey: "badgeAppIcon")
        if !badgeAppIcon {
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, error) in
                if granted && error == nil {
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = cardCount
                    }
                }
            }
        }
    }
}
