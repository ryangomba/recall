import SwiftUI

struct CardListItem: View {
    var card: Card

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.front.text)
                    .lineLimit(1)
                if !card.tags.isEmpty {
                    Text(card.tags.map({ tag in
                        "#" + tag
                    }).joined(separator: " "))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
            Spacer(minLength: 20)
            if !card.tags.contains("draft") {
                Text(card.nextReviewAt.formatRelativeReviewDays())
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CardListItem_Previews: PreviewProvider {
    static var previews: some View {
        List(testCards) { card in
            CardListItem(card: card)
                .listRowInsets(.init(UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)))
        }
    }
}
