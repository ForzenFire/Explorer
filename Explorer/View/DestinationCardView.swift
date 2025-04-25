import SwiftUI

enum CardStyle {
    case home
    case list
}

struct DestinationCardView: View {
    let post: Post
    var style: CardStyle = .list // default style

    var body: some View {
        VStack(alignment: .leading, spacing: style == .home ? 10 : 6) {
            AsyncImage(url: URL(string: post.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .aspectRatio(contentMode: .fill)
            .frame(height: style == .home ? 220 : 150)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(12)

            Text(post.title)
                .font(style == .home ? .title3.bold() : .headline)

            Text(post.location)
                .font(style == .home ? .subheadline : .caption)
                .foregroundColor(.gray)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", post.rating))
                    .font(style == .home ? .body : .caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .frame(width: style == .home ? 260 : 200)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


//struct DestinationCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DestinationCardView()
//    }
//}
