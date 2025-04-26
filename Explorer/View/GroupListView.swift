//import SwiftUI
//
//struct GroupListView: View {
//    @State private var groups: [Group] = [
//        Group(id: "1", name: "Traveller's World", imageURL: URL(string: "https://i.pravatar.cc/100?img=1"), lastMessage: "Hi, John! 👋 How are you doing?", lastUpdated: Date()),
//        Group(id: "2", name: "Hiking Lovers", imageURL: URL(string: "https://i.pravatar.cc/100?img=2"), lastMessage: "Typing...", lastUpdated: Date().addingTimeInterval(-3600)),
//        Group(id: "3", name: "ScubaBoards", imageURL: URL(string: "https://i.pravatar.cc/100?img=3"), lastMessage: "Let's meet at 18:00 near the beach!", lastUpdated: Date().addingTimeInterval(-86400)),
//        Group(id: "4", name: "Campers", imageURL: URL(string: "https://i.pravatar.cc/100?img=4"), lastMessage: "Will you come to the camping trip?", lastUpdated: Date().addingTimeInterval(-7200))
//    ]
//    
//    @State private var searchText: String = ""
//    @State private var navigateToGroup: Group?
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                List {
//                    ForEach(filteredGroups) { group in
//                        Button(action: {
//                            navigateToGroup = group
//                        }) {
//                            GroupRow(group: group)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .listStyle(.plain)
//                .searchable(text: $searchText)
//            }
//            .navigationTitle("Messages")
//            .background(
//                NavigationLink(
//                    destination: navigateToGroup.map { group in
//                        GroupChatView(groupId: group.id)
//                    },
//                    isActive: Binding(
//                        get: { navigateToGroup != nil },
//                        set: { if !$0 { navigateToGroup = nil } }
//                    ),
//                    label: { EmptyView() }
//                )
//
//            )
//        }
//    }
//
//    var filteredGroups: [Group] {
//        if searchText.isEmpty {
//            return groups
//        } else {
//            return groups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//}
//
//struct GroupRow: View {
//    let group: Group
//    
//    var body: some View {
//        HStack {
//            AsyncImage(url: group.imageURL) { image in
//                image.resizable()
//                    .scaledToFill()
//            } placeholder: {
//                Circle().fill(Color.gray.opacity(0.3))
//            }
//            .frame(width: 48, height: 48)
//            .clipShape(Circle())
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(group.name)
//                    .font(.headline)
//                
//                Text(group.lastMessage)
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//            
//            Spacer()
//            
//            Text(timeFormatted(group.lastUpdated))
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .padding(.vertical, 8)
//    }
//    
//    func timeFormatted(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: date)
//    }
//}
import SwiftUI

struct GroupListView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
//            Text("Messages")
//                .font(.title2)
//                .bold()
//                .padding(.horizontal)
//                .padding(.top)
            
            SearchBarView()
                .padding(.horizontal)
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 16) {
                    ChatRowView(imageName: "person.crop.circle.fill",
                                name: "Traveller's World",
                                message: "Hi, John! 👋 How are you doing?",
                                time: "09:46",
                                status: .doubleCheck)
                    
                    ChatRowView(imageName: "sun.max.fill",
                                name: "Hiking Lovers",
                                message: "Typing...",
                                time: "08:42",
                                status: .doubleCheck)
                    
                    ChatRowView(imageName: "person.3.fill",
                                name: "ScubaBoards",
                                message: "You: Cool! 😎 Let's meet at 18:00 near the beach!",
                                time: "Yesterday",
                                status: .singleCheck)
                    
                    ChatRowView(imageName: "car.fill",
                                name: "Campers",
                                message: "You: Hey, will you come to the camping trip on Saturday?",
                                time: "07:56",
                                status: .doubleCheck)
                }
                .padding(.top, 16)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - ChatRowView

enum MessageStatus {
    case singleCheck, doubleCheck
}

struct ChatRowView: View {
    var imageName: String
    var name: String
    var message: String
    var time: String
    var status: MessageStatus
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    if message.starts(with: "You:") {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(message == "Typing..." ? .blue : .gray)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                statusIcon
            }
        }
    }
    
    private var statusIcon: some View {
        Group {
            switch status {
            case .singleCheck:
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .foregroundColor(.gray)
            case .doubleCheck:
                HStack(spacing: -2) {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
    }
}

// MARK: - SearchBarView

struct SearchBarView: View {
    @State private var searchText = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for chats & messages", text: $searchText)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct GroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
    }
}
