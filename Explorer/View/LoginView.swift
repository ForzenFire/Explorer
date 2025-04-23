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

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)

                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                    }
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                    }
                }

                Button("Forgot Password?") {
                    showReset = true
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .sheet(isPresented: $showReset) {
                    ForgotPasswordView()
                }

                Button("Sign In") {
                    auth.login(email: email, password: password) { _ in }
                }
                .buttonStyle(.borderedProminent)

                Divider()

// Commented due to in free developer version not allowign sign in with apple!!
//              SignInWithAppleButton(
//                    onRequest: { request in
//                        request.requestedScopes = [.email, .fullName]
//                    },
//                    onCompletion: { result in
//                        switch result {
//                        case .success(let authResult):
//                            if let credential = authResult.credential as? ASAuthorizationAppleIDCredential {
//                                auth.signInWithApple(credential: credential)
//                            }
//                        default:
//                            break
//                        }
//                    }
//                )
//                .frame(height: 45)

                GoogleSignInButton(action: {
                    auth.signInWithGoogle()
                })
                .frame(height: 45)

                HStack {
                    Text("Don't have an account?")
                    Button("Register") {
                        showRegister = true
                    }
                }
                .sheet(isPresented: $showRegister) {
                    RegisterView()
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
