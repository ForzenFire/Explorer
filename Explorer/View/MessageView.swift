import SwiftUI

struct MessageView: View {
    var body: some View {
        NavigationView {
            GroupListView()
                .navigationTitle("Message")
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
