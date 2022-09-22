import SwiftUI

struct CardAttachmentView: View {
    var attachment: CardAttachment

    var body: some View {
        AsyncImage(url: URL(string: attachment.src)) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Color.gray
        }
        .aspectRatio(CGFloat(attachment.aspectRatio ?? 1), contentMode: .fit)
    }
}

struct CardFaceView: View {
    var cardFace: CardFace

    var body: some View {
        VStack {
            Text(cardFace.text)
                .multilineTextAlignment(.center)
            if let attachment = cardFace.attachment {
                CardAttachmentView(attachment: attachment)
            }
        }
    }
}

struct CardView: View {
    var card: Card
    @Binding var flipped: Bool

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    CardFaceView(cardFace: card.front)
                    if flipped {
                        Text("---")
                            .padding()
                        CardFaceView(cardFace: card.back)
                    }
                }
                .padding()
                .frame(minHeight: geometry.size.height)
            }
        }
        .frame(width: 280, height: 420, alignment: .center) // TODO: don't hardcode
        .background(Color.customBackgroundSecondary) // necessary to capture taps
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.systemGray2, lineWidth: 1 / UIScreen.main.scale)
        )
        .shadow(color: .shadow, radius: 6, x: 2, y: 2)
        .onTapGesture {
            onTap()
        }
    }

    func onTap() {
        flipped.toggle()
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: testCards[0], flipped: .constant(false))
        CardView(card: testCards[1], flipped: .constant(false))
        CardView(card: testCards[2], flipped: .constant(true))
    }
}
