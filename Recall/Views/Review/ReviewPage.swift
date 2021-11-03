import SwiftUI
import Combine

struct Badge: View {
    let count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            Text(String(count))
                .font(.system(size: 14, weight: .medium, design: .default))
                .padding(5)
                .background(Color.systemGray2)
                .clipShape(Circle())
                // custom positioning in the top-right corner
                .alignmentGuide(.top) { $0[.bottom] }
                .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
        }
    }
}

struct ReviewPage: View {
    @StateObject private var reviewCardQuery = CardQuery(store: env.cardStore, params: CardQueryParams(userID: env.sessionStore.user?.id ?? "", needsReview: true, searchText: "", tags: [], notTags: ["draft"]))
    @StateObject private var draftsCardQuery = CardQuery(store: env.cardStore, params: CardQueryParams(userID: env.sessionStore.user?.id ?? "", needsReview: true, searchText: "", tags: ["draft"], notTags: []))
    @State private var showingSettingsSheet = false
    @State private var showingCardAddSheet = false

    private var topCard: Card? {
        reviewCardQuery.cards.first
    }

    var body: some View {
        Page {
            if let topCard = topCard {
                CardReviewView(card: topCard)
            } else if reviewCardQuery.executed {
                Text("All caught up")
                    .padding()
                if !draftsCardQuery.cards.isEmpty {
                    NavigationLink(destination: DraftsPage()) {
                        Text("Review \(draftsCardQuery.cards.count) drafts")
                            .padding()
                    }
                }
            }
        }
        .navigationTitle(reviewCardQuery.cards.isEmpty ? "Review" : "Review (\(reviewCardQuery.cards.count))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Button(action: {
                        showingSettingsSheet.toggle()
                    }, label: {
                        Image(systemName: "gearshape")
                    })
                    NavigationLink(destination: DraftsPage()) {
                        if draftsCardQuery.cards.isEmpty {
                            Image(systemName: "pencil.tip.crop.circle")
                        } else {
                            Image(systemName: "pencil.tip.crop.circle")
                                .overlay(Badge(count: draftsCardQuery.cards.count))
                        }
                    }
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showingCardAddSheet.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
                if UIDevice.current.userInterfaceIdiom == .phone {
                    NavigationLink(destination: CardListPage()) {
                        Image(systemName: "list.dash")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettingsSheet) {
            NavigationView {
                SettingsPage()
            }
        }
        .sheet(isPresented: $showingCardAddSheet) {
            NavigationView {
                CardCreatePage()
            }
        }
        .onAppear {
            reviewCardQuery.runQuery()
            draftsCardQuery.runQuery()
        }
    }
}

struct ReviewPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReviewPage()
        }
    }
}
