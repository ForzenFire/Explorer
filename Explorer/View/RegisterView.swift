// View/RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @State private var user = UserModel(fullName: "", email: "", password: "", address: "", phone: "")
    @State private var agreeToTerms = false
    @StateObject var auth = AuthController()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            TextField("Full Name", text: $user.fullName)
            TextField("Email", text: $user.email)
            SecureField("Password", text: $user.password)
            TextField("Address", text: $user.address)
            TextField("Mobile", text: $user.phone)
                .keyboardType(.phonePad)

            Toggle("I agree to Terms & Conditions", isOn: $agreeToTerms)

            Button("Register") {
                guard agreeToTerms else { return }
                auth.register(user: user) { success in
                    if success { dismiss() }
                }
            }
            .disabled(!agreeToTerms)
        }
        .navigationTitle("Register")
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
