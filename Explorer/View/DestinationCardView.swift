import SwiftUI

enum CardStyle {
    case home
    case list
}

struct DestinationCardView: View {
    let post: Post
    var style: CardStyle = .list // default style

    var cardHeight: CGFloat {
        style == .home ? 360 : 250
    }

    var imageHeight: CGFloat {
        style == .home ? 220 : 150
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: imageHeight)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(16)

                if style == .home {
                    Image(systemName: "bookmark")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.white.opacity(0.85))
                        .clipShape(Circle())
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(post.title)
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                        Text(String(format: "%.1f", post.rating))
                            .font(.subheadline)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text(post.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                HStack(spacing: -10) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }

                    Text("+50")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
        .frame(width: style == .home ? 300 : nil, height: cardHeight)
    }

}
