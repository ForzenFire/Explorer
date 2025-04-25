import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @StateObject var auth = AuthController()
    @State private var showRegister = false
    @State private var showReset = false
    @State private var showError = false
    @State private var showFaceIDPrompt = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    VStack(spacing: 16) {
                        Text("Sign In")
                            .font(.largeTitle.bold())
                            .padding(.bottom, 20)

                        VStack(spacing: 20) {
                            CustomTextField(
                                text: $email,
                                placeholder: "Email",
                                icon: "envelope"
                            )
                            .textContentType(.username)

                            CustomSecureField(
                                text: $password,
                                placeholder: "Password",
                                showPassword: $showPassword
                            )
                            .textContentType(.password)

                            Button("Forgot Password?") {
                                showReset = true
                            }
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 8)
                        }

                        Button(action: login) {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.top, 20)

                        if auth.isFaceIDEnabled {
                            Button(action: useFaceIDLogin) {
                                HStack {
                                    Image(systemName: "faceid")
                                    Text("Login with Face ID")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    VStack(spacing: 16) {
                        Text("Or continue with")
                            .foregroundColor(.gray)

                        VStack(spacing: 12) {
                            SocialLoginButton(
                                icon: "applelogo",
                                text: "Continue with Apple",
                                action: {}
                            )

                            SocialLoginButton(
                                icon: "g.circle.fill",
                                text: "Continue with Google",
                                action: {
                                    auth.signInWithGoogle()
                                }
                            )

                            SocialLoginButton(
                                icon: "f.circle.fill",
                                text: "Continue with Facebook",
                                action: {}
                            )
                        }

                        HStack {
                            Text("Don't have an account?")
                            Button("Sign up") {
                                showRegister = true
                            }
                            .foregroundColor(.blue)
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                .onChange(of: auth.errorMessage) {
                    if !auth.errorMessage.isEmpty {
                        showError = true
                    }
                }
                .alert(isPresented: $showError) {
                    Alert(
                        title: Text("Login Error"),
                        message: Text(auth.errorMessage),
                        dismissButton: .default(Text("OK")) {
                            auth.errorMessage = ""
                        }
                    )
                }
                .alert("Enable Face ID for future logins?", isPresented: $showFaceIDPrompt) {
                    Button("Enable") {
                        auth.isFaceIDEnabled = true
                    }
                    Button("Not Now", role: .cancel) {}
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showReset) {
                ForgotPasswordView()
            }
        }
    }

    private func login() {
        auth.login(email: email, password: password) { success in
            if success {
                // Save credentials to Keychain
                auth.saveCredentialsToKeychain(email: email, password: password)

                // Ask user if they want to enable Face ID
                BiometricAuth.authenticateWithBiometrics(reason: "Enable Face ID for faster login?") { faceIDSuccess, error in
                    if faceIDSuccess {
                        auth.isFaceIDEnabled = true
                        print("✅ Face ID enabled")
                    } else {
                        print("❌ Face ID setup canceled or failed")
                    }

                    // ⚠️ Trigger login success navigation AFTER biometric
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                    }
                }
            } else {
                // Optional: show an alert if login fails
                print("❌ Login failed")
            }
        }
    }


    private func useFaceIDLogin() {
        BiometricAuth.authenticateWithBiometrics(reason: "Log in with Face ID to continue") { success, error in
            if success {
                auth.loginWithSavedCredentials { loginSuccess in
                    if loginSuccess {
                        print("✅ Logged in using Face ID")
                    } else {
                        print("❌ Failed to login with saved credentials")
                    }
                }
            } else {
                print("❌ Biometric authentication failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }


    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray.opacity(0.2)))
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    @Binding var showPassword: Bool

    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.gray)
            if showPassword {
                TextField(placeholder, text: $text)
            } else {
                SecureField(placeholder, text: $text)
            }
            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray.opacity(0.2)))
    }
}

struct SocialLoginButton: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(text)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray.opacity(0.2)))
        }
        .foregroundColor(.primary)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
