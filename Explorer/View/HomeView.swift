import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var profileController = ProfileController()
    @StateObject var postController = PostController()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Profile Header
                    HStack {
                        HStack(spacing: 10) {
                            if let urlString = profileController.userProfile?.profileImageUrl,
                               let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())

                            } else {
                              Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 36, height: 36)
                            }

                                Text(profileController.userProfile?.fullName ?? "Hi there!")
                                    .font(.subheadline)
                                    .bold()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())

                            Spacer()
                            }
                            .padding()
//                    .padding(.horizontal, 14)
//                    .padding(.vertical, 8)
//                    .background(Color(.systemGray6))
//                    .clipShape(Capsule())
//                    .padding(.top, 10)
//                    .padding(.horizontal)

                    // Main Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Explore the")
                            .font(.system(size: 28, weight: .semibold))

                        HStack(spacing: 0) {
                            Text("Beautiful ")
                                .font(.system(size: 30, weight: .bold))
                            Text("Island!")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)

                    // Section Title
                    HStack {
                        Text("Popular Destination")
                            .font(.title3.weight(.semibold))
                        Spacer()
                        NavigationLink(destination: AllDestinationsView()) {
                            Text("View All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)

                    // Horizontal Card Scroll
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
