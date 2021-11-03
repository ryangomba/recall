import SwiftUI

struct DraftsPage: View {
    @StateObject private var cardQuery = CardQuery(store: env.cardStore, params: CardQueryParams(userID: env.sessionStore.user?.id ?? "", needsReview: false, searchText: "", tags: ["draft"], notTags: []))
    @State private var editMode = EditMode.inactive
    @State private var selectedCardIDs = Set<String>()
    @State private var showingCardAddSheet = false

    var body: some View {
        Page {
            List(cardQuery.cards, id: \.self.id, selection: $selectedCardIDs) { card in
                NavigationLink(destination: CardEditPage(card: card)) {
                    CardListItem(card: card)
                }
                .listRowInsets(.init(UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)))
                .listRowBackground(Color.customBackground)
                .swipeActions {
                    Button(role: .destructive) {
                        onDelete(cardID: card.id)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $cardQuery.params.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle(cardQuery.cards.isEmpty ? "Drafts" : "Drafts (\(cardQuery.cards.count))")
        .navigationBarBackButtonHidden(editMode == .active)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if (editMode == .active) {
                    Button(action: onDone, label: {
                        Text("Done")
                    })
                } else if (editMode == .inactive) {
                    Button(action: onEdit, label: {
                        Text("Edit")
                    })
                    Button(action: {
                        showingCardAddSheet.toggle()
                    }, label: {
                        Label("Add card", systemImage: "plus")
                    })
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if !selectedCardIDs.isEmpty {
                    Button(action: onBatchDelete, label: {
                        Text("Delete card(s)")
                    })
                }
            }
        }
        .sheet(isPresented: $showingCardAddSheet) {
            NavigationView {
                CardCreatePage()
            }
        }
        .environment(\.editMode, $editMode)
        .onAppear {
            cardQuery.runQuery()
        }
    }

    func onEdit() {
        editMode = .active
    }

    func onDone() {
        stopEditing()
    }

    func onDelete(cardID: String) {
        CardService.deleteCards([cardID])
    }

    func onBatchDelete() {
        CardService.deleteCards(selectedCardIDs)
        stopEditing()
    }

    func stopEditing() {
        selectedCardIDs = []
        editMode = .inactive
    }
}

struct DraftsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DraftsPage()
        }
    }
}
