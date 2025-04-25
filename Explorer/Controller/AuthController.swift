import FirebaseAuth
import Firebase
import AuthenticationServices
import GoogleSignIn
import FirebaseFirestore
import LocalAuthentication

class AuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage = ""

    // MARK: - Register (Email/Password)
    func register(user: UserModel, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let uid = result?.user.uid else {
                self.errorMessage = "Failed to get user ID"
                completion(false)
                return
            }

            self.saveUserToFirestore(
                uid: uid,
                email: user.email,
                fullName: user.fullName,
                address: user.address,
                phone: user.phone,
                profileImage: user.profileImageUrl,
                completion: completion
            )
        }
    }

    // MARK: - Login (Email/Password)
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self.isAuthenticated = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
            }
            completion(true)
        }
    }

    // MARK: - Reset Password
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Sign in with Google
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

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Missing Google ID/Access Token")
                return
            }

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

                guard let firebaseUser = result?.user else { return }

                self.saveUserToFirestore(
                    uid: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    fullName: firebaseUser.displayName ?? "",
                    address: nil,
                    phone: firebaseUser.phoneNumber,
                    profileImage: firebaseUser.photoURL?.absoluteString
                ) { _ in }

                self.isAuthenticated = true
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                }
            }
        }
    }

    // MARK: - Sign in with Apple
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else { return }

        let firebaseCredential = OAuthProvider.credential(
            providerID: .apple,
            idToken: tokenString,
            rawNonce: "",
            accessToken: nil
        )

        Auth.auth().signIn(with: firebaseCredential)
    }

    // MARK: - Firestore Save
    private func saveUserToFirestore(uid: String, email: String, fullName: String?, address: String?, phone: String?, profileImage: String?, completion: @escaping (Bool) -> Void = { _ in }) {
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "uid": uid,
            "email": email
        ]
        if let fullName = fullName { data["fullName"] = fullName }
        if let address = address { data["address"] = address }
        if let phone = phone { data["phone"] = phone }
        if let profileImage = profileImage { data["profileImage"] = profileImage }

        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                print("❌ Firestore Save Error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                print("✅ User saved to Firestore.")
                completion(true)
            }
        }
    }

    // MARK: - Save Credentials to Keychain
    func saveCredentialsToKeychain(email: String, password: String) {
        if let emailData = email.data(using: .utf8),
           let passwordData = password.data(using: .utf8) {
            KeychainManager.shared.save(emailData, service: "ExplorerApp", account: "email")
            KeychainManager.shared.save(passwordData, service: "ExplorerApp", account: "password")
        }
    }

    // MARK: - Retrieve Credentials
    func retrieveCredentialsFromKeychain() -> (email: String, password: String)? {
        guard let emailData = KeychainManager.shared.load(service: "ExplorerApp", account: "email"),
              let passwordData = KeychainManager.shared.load(service: "ExplorerApp", account: "password"),
              let email = String(data: emailData, encoding: .utf8),
              let password = String(data: passwordData, encoding: .utf8) else {
            return nil
        }
        return (email, password)
    }

    // MARK: - Biometric Face ID Login
    func loginWithSavedCredentials(completion: @escaping (Bool) -> Void) {
        guard let credentials = retrieveCredentialsFromKeychain() else {
            completion(false)
            return
        }

        BiometricAuth.authenticateWithBiometrics(reason: "Log in with Face ID") { success, error in
            DispatchQueue.main.async {
                if success {
                    self.login(email: credentials.email, password: credentials.password, completion: completion)
                } else {
                    self.errorMessage = "Face ID authentication failed."
                    completion(false)
                }
            }
        }
    }

    // MARK: - Face ID Opt-in (UserDefaults)
    var isFaceIDEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "faceIDEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "faceIDEnabled") }
    }
}
