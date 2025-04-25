import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var profileController = ProfileController()
    @StateObject var postController = PostController()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    if let urlString = profileController.userProfile?.profileImageUrl,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    
                    Text(profileController.userProfile?.fullName ?? "Hi there!")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                .padding()

                HStack {
                    Text("Explore the")
                        .font(.title2)
                    +
                    Text(" Beautiful Island!")
                        .foregroundColor(.orange)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)

                HStack {
                    Text("Popular Destination")
                        .font(.headline)
                    Spacer()
                    NavigationLink(destination: AllDestinationsView()) {
                        Text("View All")
                    }
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(postController.topPosts) { post in
                            DestinationCardView(post: post, style: .home)

                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationBarHidden(true)
            .onAppear {
                if let uid = Auth.auth().currentUser?.uid {
                    profileController.fetchUserProfile(uid: uid)
                }
                postController.fetchTopPosts()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
