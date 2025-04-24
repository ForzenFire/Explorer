import SwiftUI

struct RegisterView: View {
    @State private var user = UserModel(fullName: "", email: "", password: "", address: "", phone: "")
    @State private var agreeToTerms = false
    @StateObject var auth = AuthController()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Sign Up")
                        .font(.largeTitle.bold())
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 16) {
                        CustomTextField(
                            text: $user.fullName,
                            placeholder: "Full Name",
                            icon: "person"
                        )
                        
                        CustomTextField(
                            text: $user.email,
                            placeholder: "Email",
                            icon: "envelope"
                        )
                        
                        CustomSecureField(
                            text: $user.password,
                            placeholder: "Password",
                            showPassword: .constant(false)
                        )
                        
                        CustomTextField(
                            text: $user.address,
                            placeholder: "Address",
                            icon: "house"
                        )
                        
                        HStack {
                            Text("+94")
                                .padding(.leading)
                            TextField("Mobile", text: $user.phone)
                                .keyboardType(.phonePad)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray.opacity(0.2)))
                        
                        HStack {
                            Toggle("", isOn: $agreeToTerms)
                                .labelsHidden()
                            Text("By creating an account or signing you agree to our **Terms and Conditions**")
                                .font(.footnote)
                        }
                    }
                    
                    Button(action: register) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!agreeToTerms)
                }
                .padding()
            }
            .navigationTitle("Register")
        }
    }
    
    private func register() {
        guard agreeToTerms else { return }
        auth.register(user: user) { success in
            if success { dismiss() }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
