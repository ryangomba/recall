import SwiftUI

struct CardView: View {
    var card: Card
    @Binding var flipped: Bool

    var body: some View {
        VStack {
            Text(card.front)
                .multilineTextAlignment(.center)
            if flipped {
                Text("---")
                    .padding()
                Text(card.back)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
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
