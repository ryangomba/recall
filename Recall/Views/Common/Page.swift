import SwiftUI

struct Page<Content: View>: View {
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            Color.customBackground.ignoresSafeArea()
            VStack(content: content)
        }
    }
}

struct Page_Previews: PreviewProvider {
    static var previews: some View {
        Page {
            Text("Hello")
        }
    }
}
