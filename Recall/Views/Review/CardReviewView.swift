import SwiftUI

struct CardReviewView: View {
    var card: Card
    @State var cardFlipped = false
    @State var editingCard = false

    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottomTrailing) {
                CardView(card: card, flipped: $cardFlipped)
                Button(action: onEditButtonPressed) {
                    Image(systemName: "square.and.pencil")
                        .padding()
                }
            }
            Spacer()
            HStack(alignment: .center, spacing: 44) {
                if cardFlipped {
                    Button(action: onReviewFailed) {
                        Image(systemName: "x.circle")
                            .resizable()
                            .frame(width: 64, height: 64, alignment: .center)
                    }
                }
                if cardFlipped {
                    Button(action: onReviewSucceeded) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 64, height: 64, alignment: .center)
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 44, trailing: 0))
            .height(100)
        }
        .sheet(isPresented: $editingCard) {
            NavigationView {
                CardEditPage(card: card)
            }
        }
    }

    private func onEditButtonPressed() {
        editingCard.toggle()
    }

    private func onReviewSucceeded() {
        reviewCard(success: true)
    }

    private func onReviewFailed() {
        reviewCard(success: false)
    }

    private func reviewCard(success: Bool) {
        CardService.reviewCard(card: card, success: success)
        cardFlipped = false
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardReviewView(card: testCards[0])
        }
    }
}
