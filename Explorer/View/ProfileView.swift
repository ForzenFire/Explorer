import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var userEmail = Auth.auth().currentUser?.email ?? "Unknown"
    @State private var userName = Auth.auth().currentUser?.displayName ?? "User"

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Profile header
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 4) {
                        Text(userName)
                            .font(.headline)
                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                
                // Menu items
                VStack(spacing: 8) {
                    ForEach(menuItems) { item in
                        if item.isButton {
                            NavigationLink {
                                // Empty view for navigation
                                Text(item.title)
                            } label: {
                                HStack {
                                    Image(systemName: item.icon)
                                        .foregroundColor(.blue)
                                    Text(item.title)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button(action: logout) {
                                HStack {
                                    Image(systemName: item.icon)
                                        .foregroundColor(.red)
                                    Text(item.title)
                                        .foregroundColor(.red)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        if item.id != menuItems.last?.id {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarHidden(true)
        }
    }
    
    private var menuItems: [MenuItem] {
        [
            MenuItem(id: 0, title: "Profile", icon: "person", isButton: true),
            MenuItem(id: 1, title: "Bookmarked", icon: "bookmark", isButton: true),
            MenuItem(id: 2, title: "Previous Trips", icon: "clock", isButton: true),
            MenuItem(id: 3, title: "Settings", icon: "gear", isButton: true),
            MenuItem(id: 4, title: "Version", icon: "info.circle", isButton: true),
            MenuItem(id: 5, title: "Logout", icon: "arrow.uturn.left", isButton: false)
        ]
    }
    
    private struct MenuItem: Identifiable {
        let id: Int
        let title: String
        let icon: String
        let isButton: Bool
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
