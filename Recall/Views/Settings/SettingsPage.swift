import SwiftUI

struct SettingsPage: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session: SessionStore
    @AppStorage("badgeAppIcon") var badgeAppIcon = false

    var body: some View {
        Page {
            List {
                Section {
                    Toggle("Badge app icon", isOn: $badgeAppIcon)
                }
                Section {
                    Button("Sign out", action: onSignOut)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    func onSignOut() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + DISMISSAL_DURATION) {
            session.signOut()
        }
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsPage()
        }
    }
}
