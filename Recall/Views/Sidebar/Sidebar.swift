import SwiftUI

struct Sidebar: View {
    @StateObject private var reviewCardQuery = CardQuery(store: env.cardStore, params: CardQueryParams(userID: env.sessionStore.user?.id ?? "", needsReview: true, searchText: "", tags: [], notTags: ["draft"]))
    @StateObject private var draftsCardQuery = CardQuery(store: env.cardStore, params: CardQueryParams(userID: env.sessionStore.user?.id ?? "", needsReview: true, searchText: "", tags: ["draft"], notTags: []))
    @State private var selectedPage: String? = "review"

    var body: some View {
        List {
            Section {
                NavigationLink(destination: ReviewPage(), tag: "review", selection: $selectedPage) {
                    Label(reviewCardQuery.cards.isEmpty ? "Review" : "Review (\(reviewCardQuery.cards.count))", systemImage: "calendar")
                }
                NavigationLink(destination: DraftsPage(), tag: "drafts", selection: $selectedPage) {
                    Label(draftsCardQuery.cards.isEmpty ? "Drafts" : "Drafts (\(draftsCardQuery.cards.count))", systemImage: "pencil.tip.crop.circle")
                }
                NavigationLink(destination: CardListPage(), tag: "list", selection: $selectedPage) {
                    Label("All cards", systemImage: "list.dash")
                }
                NavigationLink(destination: SettingsPage(), tag: "settings", selection: $selectedPage) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .onAppear {
            reviewCardQuery.runQuery()
            draftsCardQuery.runQuery()
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}
