import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var userEmail = Auth.auth().currentUser?.email ?? "Unknown"
    @State private var userName = Auth.auth().currentUser?.displayName ?? "User"

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.top, 20)
                Text(userName).font(.title2).bold()
                Text(userEmail).font(.subheadline).foregroundColor(.gray)
            }

            List {
                Section {
                    Label("Profile", systemImage: "person")
                    Label("Bookmarked", systemImage: "bookmark")
                    Label("Previous Trips", systemImage: "clock")
                    Label("Settings", systemImage: "gear")
                    Label("Version", systemImage: "info.circle")
                    
                    Button(action: logout) {
                        Label("Logout", systemImage: "arrow.uturn.left")
                            .foregroundColor(.red)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .frame(minHeight: 400)
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Profile")
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            // redirect to login
            NotificationCenter.default.post(name: NSNotification.Name("logout"), object: nil)
        } catch {
            print("Logout error: \(error)")
        }
    }
}


struct ProfileView_Preview: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
