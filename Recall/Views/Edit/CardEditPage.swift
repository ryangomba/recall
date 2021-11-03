import SwiftUI

struct CardEditPage: View {
    var card: Card
    @Environment(\.dismiss) var dismiss
    @StateObject private var formData = CardFormData()

    var body: some View {
        Page {
            CardForm(formData: formData)
        }
        .interactiveDismissDisabled()
        .navigationTitle("Edit card")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button("Save", action: onSave)
                    .disabled(!formData.isValid)
            }
        }
        .onAppear {
            formData.front = card.front
            formData.back = card.back
            formData.reversed = card.reversedCardID != nil
        }
    }

    func onDelete() {
        CardService.deleteCards([card.id])
        dismiss()
    }

    func onSave() {
        var updatedCard = card
        updatedCard.front = formData.front
        updatedCard.back = formData.back
        if formData.isDraft {
            updatedCard.tags.update(with: "draft")
        } else {
            updatedCard.tags.remove("draft")
        }
        var cardsToDelete: Set<String> = []
        if card.reversedCardID == nil && formData.reversed {
            // create reversed card
            let reversedCard = CardService.generateReversedCard(card)
            env.cardStore.create(reversedCard)
            updatedCard.reversedCardID = reversedCard.id
        } else if card.reversedCardID != nil && !formData.reversed {
            // delete reversed card
            let reversedCardID = card.reversedCardID!
            updatedCard.reversedCardID = nil
            cardsToDelete.update(with: reversedCardID)
        }
        env.cardStore.update(updatedCard)
        if !cardsToDelete.isEmpty {
            env.cardStore.delete(ids: cardsToDelete)
        }
        dismiss()
    }
}

struct CardEditPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardEditPage(card: testCards[0])
        }
    }
}
