import SwiftUI

struct AllDestinationsView: View {
    @StateObject var postController = PostController()
    
    // Define a grid with fixed width to match visual consistency
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top bar
            HStack {
                Text("All Popular Destinations")
                    .font(.title2)
                    .bold()
                
                Spacer()

                NavigationLink(destination: AddPostView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal)

            // Grid
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 46) {
                    ForEach(postController.allPosts) { post in
                        DestinationCardView(post: post, style: .list)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .padding(.top)
        .background(Color(.systemBackground))
        .onAppear {
            postController.fetchAllPosts()
        }
    }
}

struct AllDestinationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AllDestinationsView()
        }
    }
}
