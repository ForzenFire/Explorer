import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @StateObject var auth = AuthController()

    var body: some View {
        VStack {
            Text("Reset your password")
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)

            Button("Send Reset Link") {
                auth.resetPassword(email: email)
            }
        }
        .padding()
    }
}
