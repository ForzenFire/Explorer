import SwiftUI

struct DestinationCardView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: post.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 150)
            .cornerRadius(12)

            Text(post.title).bold()
            Text(post.location).font(.subheadline).foregroundColor(.gray)

            HStack {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text(String(format: "%.1f", post.rating))
            }
        }
        .frame(width: 200)
        .padding(.vertical, 4)
    }
}

//struct DestinationCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DestinationCardView()
//    }
//}
