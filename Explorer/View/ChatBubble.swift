//import SwiftUI
//
//enum MessageDirection {
//    case sender
//    case receiver
//}
//
//struct ChatBubble: View {
//    let message: Message // Message is your model
//    let currentUserId: String // Pass the current user ID to determine direction
//
//private var isCurrentUser: Bool {
//    message.senderId == currentUserId
//}
//
//private var direction: MessageDirection {
//    isCurrentUser ? .sender : .receiver
//}
//
//var body: some View {
//    HStack(alignment: .bottom, spacing: 8) {
//        if direction == .receiver {
//            avatar
//        }
//
//        VStack(alignment: direction == .sender ? .trailing : .leading, spacing: 4) {
//            if direction == .receiver {
//                Text(message.displayName)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//
//            Text(message.text)
//                .padding(10)
//                .background(direction == .sender ? Color.blue : Color.gray.opacity(0.2))
//                .foregroundColor(direction == .sender ? .white : .primary)
//                .cornerRadius(12)
//
//            Text(timeFormatted(message.timestamp))
//                .font(.caption2)
//                .foregroundColor(.gray)
//        }
//
//        if direction == .sender {
//            avatar
//        }
//    }
//    .padding(.horizontal)
//    .frame(maxWidth: .infinity, alignment: direction == .sender ? .trailing : .leading)
//}
//
//private var avatar: some View {
//    AsyncImage(url: URL(string: message.photoURL ?? "")) { image in
//        image
//            .resizable()
//            .scaledToFill()
//    } placeholder: {
//        Circle()
//            .fill(Color.gray.opacity(0.3))
//    }
//    .frame(width: 32, height: 32)
//    .clipShape(Circle())
//}
//
//private func timeFormatted(_ date: Date) -> String {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "h:mm a"
//    return formatter.string(from: date)
//    }
//}
