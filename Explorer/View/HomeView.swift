import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var profileController = ProfileController()
    @StateObject var postController = PostController()
    @State private var selectedIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    @StateObject private var weatherController = WeatherController()

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
                    
                    WeatherView(weatherController: weatherController)

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
                    .padding(.top, 7)
                    .padding(.horizontal)

                    // Swipeable Stacked Cards
                    if !postController.topPosts.isEmpty {
                        ZStack {
                            ForEach(postController.topPosts.indices, id: \.self) { index in
                                let post = postController.topPosts[index]

                                let isTopCard = index == selectedIndex
                                let isNextCard = index == selectedIndex + 1
                                let topCardOffset: CGFloat = dragOffset
                                let nextCardOffset: CGFloat = max(dragOffset, 0) / 2

                                DestinationCardView(post: post, style: .home)
                                    .frame(width: UIScreen.main.bounds.width * 0.82)
                                    .offset(x: isTopCard ? topCardOffset : (isNextCard ? nextCardOffset : 0))
                                    .scaleEffect(isTopCard ? 1.0 : 0.95)
                                    .opacity(index < selectedIndex ? 0 : 1)
                                    .zIndex(selectedIndex == index ? 2 : 1)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedIndex)
                            }
                        }
                        .frame(height: 400)
                        .gesture(
                            DragGesture()
                                .updating($dragOffset, body: { value, state, _ in
                                    state = value.translation.width
                                })
                                .onEnded { value in
                                    let threshold: CGFloat = 80
                                    if value.translation.width > threshold && selectedIndex < postController.topPosts.count - 1 {
                                        selectedIndex += 1
                                    } else if value.translation.width < -threshold && selectedIndex > 0 {
                                        selectedIndex -= 1
                                    }
                                }
                        )
                        .padding(.top)
                    } else {
                        ProgressView("Loading destinations...")
                            .frame(height: 400)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
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
