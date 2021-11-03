import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if (sessionStore.user != nil) {
                NavigationView {
                    if UIDevice.current.userInterfaceIdiom != .phone {
                        Sidebar()
                    } else {
                        ReviewPage()
                    }
                }
            } else {
                AuthPage()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
