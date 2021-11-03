import Combine
import Firebase
import FirebaseAuth
import FirebaseAuthCombineSwift

class SessionStore : ObservableObject {
    @Published var user: User?
    private var auth: FirebaseAuth.Auth
    private var authenticationStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        auth = Auth.auth()
        user = userFromFirebaseUser(auth.currentUser)
        listen()
    }

    private func userFromFirebaseUser(_ user: FirebaseAuth.User?) -> User? {
        guard let user = user else {
            return nil
        }
        return User(
            id: user.uid,
            email: user.email,
            displayName: user.displayName
        )
    }

    private func listen() {
        if let handle = authenticationStateHandler {
            auth.removeStateDidChangeListener(handle)
        }
        authenticationStateHandler = auth.addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.user = self.userFromFirebaseUser(user)
            } else {
                self.user = nil
            }
        }
    }

    func signInAnonymously() {
        auth.signInAnonymously()
    }

    func signInWithApple(idToken: String, rawNonce: String) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idToken,
                                                  rawNonce: rawNonce)
        auth.signIn(with: credential) { (authResult, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            Firestore.firestore().clearPersistence()
            self.user = nil
        } catch {
            fatalError("Cannot sign out")
        }
    }
}
