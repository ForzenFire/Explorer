import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var profileController = ProfileController()
    @StateObject var postController = PostController()
    @State private var selectedIndex: Int = 0

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

                    // Swipeable Stacked Cards
                    GeometryReader { outerGeometry in
                        let cardWidth = outerGeometry.size.width * 0.8
                        let spacing: CGFloat = 16

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: spacing) {
                                ForEach(Array(postController.topPosts.enumerated()), id: \.1.id) { index, post in
                                    DestinationCardView(post: post, style: .home)
                                        .frame(width: cardWidth)
                                        .scaleEffect(index == selectedIndex ? 1.0 : 0.94)
                                        .offset(x: CGFloat(index - selectedIndex) * (cardWidth * 0.1))
                                        .zIndex(Double(postController.topPosts.count - index))
                                        .animation(.easeInOut(duration: 0.3), value: selectedIndex)
                                }
                            }
                            .padding(.horizontal, (outerGeometry.size.width - cardWidth) / 2)
                        }
                        .content.offset(x: -CGFloat(selectedIndex) * (cardWidth + spacing))
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    if value.translation.width < -threshold && selectedIndex < postController.topPosts.count - 1 {
                                        selectedIndex += 1
                                    } else if value.translation.width > threshold && selectedIndex > 0 {
                                        selectedIndex -= 1
                                    }
                                }
                        )
                    }
                    .frame(height: 400)

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
