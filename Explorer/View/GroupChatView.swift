//import SwiftUI
//import FirebaseFirestore
//
//struct GroupChatView: View {
//    let groupId: String
//    @State private var messages: [Message] = []
//    @State private var newMessage = ""
//    @State private var listener: ListenerRegistration?
//    
//    var body: some View {
//        VStack {
//            ScrollViewReader { scrollView in
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(messages) { message in
//                            ChatBubble(message: message)
//                                .id(message.id)
//                        }
//                    }
//                    .padding(.top)
//                }
//                .onChange(of: messages.count) { _ in
//                    if let last = messages.last {
//                        scrollView.scrollTo(last.id, anchor: .bottom)
//                    }
//                }
//            }
//            
//            HStack {
//                TextField("Message...", text: $newMessage)
//                    .padding(12)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                
//                Button(action: sendMessage) {
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor(.blue)
//                        .padding(8)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Group Chat")
//        .onAppear {
//            fetchMessages()
//        }
//        .onDisappear {
//            listener?.remove()
//        }
//    }
//    
//    private func fetchMessages() {
//        let db = Firestore.firestore()
//        listener = db.collection("group_chats")
//            .document(groupId)
//            .collection("messages")
//            .order(by: "timestamp")
//            .addSnapshotListener { snapshot, error in
//                guard let documents = snapshot?.documents else { return }
//                self.messages = documents.compactMap { doc in
//                    try? doc.data(as: Message.self)
//                }
//            }
//    }
//    
//    private func sendMessage() {
//        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//        let db = Firestore.firestore()
//        let message = Message(id: UUID().uuidString,
//                              text: newMessage,
//                              senderId: "your_user_id", // Replace with actual user ID
//                              timestamp: Date())
//        do {
//            try db.collection("group_chats")
//                .document(groupId)
//                .collection("messages")
//                .document(message.id)
//                .setData(from: message)
//            newMessage = ""
//        } catch {
//            print("Error sending message: \(error)")
//        }
//    }
//}
