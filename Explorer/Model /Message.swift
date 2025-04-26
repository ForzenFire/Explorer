import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    // Firestore document ID let text: String
    // Message text let senderId: String
    // UID of sender let displayName: String
    // Sender's display name let photoURL: String?
    // Sender's profile image (optional) let timestamp: Date
    // When message was sent
}
