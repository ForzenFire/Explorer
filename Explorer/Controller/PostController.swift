import FirebaseFirestore
import Firebase
import FirebaseStorage

class PostController: ObservableObject {
    @Published var topPosts: [Post] = []
    @Published var allPosts: [Post] = []

    func fetchTopPosts(limit: Int = 5) {
        Firestore.firestore().collection("posts")
            .order(by: "rating", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.topPosts = docs.compactMap { doc in
                    let data = doc.data()
                    return Post(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        location: data["location"] as? String ?? "",
                        rating: data["rating"] as? Double ?? 0.0,
                        imageUrl: data["imageUrl"] as? String ?? ""
                    )
                }
            }
        }
        
        func fetchAllPosts() {
            Firestore.firestore().collection("posts")
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else { return }
                    self.allPosts = docs.compactMap { doc in
                        let data = doc.data()
                        return Post(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            location: data["location"] as? String ?? "",
                            rating: data["rating"] as? Double ?? 0.0,
                            imageUrl: data["imageUrl"] as? String ?? ""
                        )
                    }
                }
        }
    
    func uploadPost(title: String, location: String, rating: Double, imageData: Data, completion: @escaping (Bool) -> Void) {
        let postID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("post_images/\(postID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Failed to upload image: \(error.localizedDescription)")
                completion(false)
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("❌ Failed to get image download URL: \(error?.localizedDescription ?? "Unknown")")
                    completion(false)
                    return
                }

                let postData: [String: Any] = [
                    "title": title,
                    "location": location,
                    "rating": rating,
                    "imageUrl": downloadURL.absoluteString,
                    "timestamp": Timestamp(date: Date())
                ]

                Firestore.firestore().collection("posts").document(postID).setData(postData) { error in
                    if let error = error {
                        print("❌ Failed to upload post data: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("✅ Post uploaded successfully")
                        completion(true)
                    }
                }
            }
        }
    }

    }
