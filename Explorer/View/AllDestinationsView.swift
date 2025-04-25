import SwiftUI

struct AllDestinationsView: View {
    @StateObject var postController = PostController()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("All Popular Destinations")
                    .font(.title2)
                    .bold()
                
                Spacer()

                NavigationLink(destination: AddPostView()) {
                    Label("Add", systemImage: "plus")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)


            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(postController.allPosts) { post in
                        DestinationCardView(post: post)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            postController.fetchAllPosts()
        }
    }
}

