import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

fileprivate var currentNonce: String? = nil

struct AuthPage : View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var sessionStore: SessionStore
    @State var loading = false

    var body: some View {
        Page {
            VStack {
                SignInWithAppleButton(.signIn) { request in
                    currentNonce = randomNonceString()
                    request.nonce = sha256(currentNonce!)
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        print("Authorization successful.")
                        signInWithApple(authorization: authorization)
                    case .failure(let error):
                        print("Authorization failed: " + error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .height(44)
                .padding()
                Button(action: signInAnonymously) {
                    Text("Sign in anonymously")
                        .padding()
                }
            }
            .padding()
        }
    }

    func signInAnonymously() {
        loading = true
        sessionStore.signInAnonymously()
    }

    func signInWithApple(authorization: ASAuthorization) {
        let appleIDCredential = authorization.credential as! ASAuthorizationAppleIDCredential
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            fatalError("Unable to fetch identity token")
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            fatalError("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        }
        loading = true
        sessionStore.signInWithApple(idToken: idTokenString, rawNonce: nonce)
    }
}

struct AuthPage_Previews: PreviewProvider {
    static var previews: some View {
        AuthPage()
    }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }

        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
}

