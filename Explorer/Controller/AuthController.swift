import FirebaseAuth
import Firebase
import AuthenticationServices
import GoogleSignIn

class AuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage = ""

    func register(user: UserModel, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            // Optionally store additional info in Firestore
            let db = Firestore.firestore()
            db.collection("users").document(result!.user.uid).setData([
                "fullName": user.fullName,
                "email": user.email,
                "address": user.address,
                "phone": user.phone
            ])
            completion(true)
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            completion(true)
        }
    }

    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signInWithGoogle() {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            let config = GIDConfiguration(clientID: clientID)

            guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow })?.rootViewController else {
                    print("❌ Failed to get rootViewController")
                    return
            }

            GIDSignIn.sharedInstance.configuration = config

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    print("Google Sign-In Error: \(error.localizedDescription)")
                    return
                }

                guard
                    let user = signInResult?.user
                else {
                    print("❌ Missing Google ID/Access Token")
                    return
                }

                let idToken = user.idToken?.tokenString
                let accessToken = user.accessToken.tokenString


                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )

                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print("Firebase Sign-In Error: \(error.localizedDescription)")
                        return
                    }

                    print("✅ Signed in with Google as: \(result?.user.email ?? "Unknown Email")")
                }
            }
        }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken else { return }
        guard let tokenString = String(data: token, encoding: .utf8) else { return }

        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                           idToken: tokenString,
                                                           rawNonce: "")
        Auth.auth().signIn(with: firebaseCredential)
    }
}
