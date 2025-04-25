import FirebaseFirestore
import Firebase

class ProfileController: ObservableObject {
    @Published var userProfile: UserModel?
    
    func fetchUserProfile(uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (snapshot, error) in
            guard let data = snapshot?.data(), error == nil else { return }
            
            self.userProfile = UserModel(
                fullName: data["fullName"] as? String ?? "",
                email: data["email"] as? String ?? "",
                password: data["password"] as? String ?? "",
                address: data["address"] as? String ?? "",
                phone: data["phone"] as? String ?? "",
                profileImageUrl: data["profileImageUrl"] as? String
            )
        }
    }
}
