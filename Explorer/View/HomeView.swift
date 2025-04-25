import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var profileController = ProfileController()
    @StateObject var postController = PostController()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with profile and greeting
                    HStack {
                        if let urlString = profileController.userProfile?.profileImageUrl,
                           let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                        
                        Text(profileController.userProfile?.fullName ?? "Dlishan")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Explore text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Explore the")
                            .font(.title2)
                            .foregroundColor(.black)
                        Text("Beautiful Island!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    
                    // Popular Destinations section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Popular Destination")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: AllDestinationsView()) {
                                Text("View all")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Horizontal scroll of destinations
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(postController.topPosts) { post in
                                    DestinationCardView(post: post)
                                        .frame(width: 200)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationBarHidden(true)
            }
            .background(Color(.systemBackground))
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
