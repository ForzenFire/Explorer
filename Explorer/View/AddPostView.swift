import SwiftUI
import PhotosUI

struct AddPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var postController = PostController()
    
    @State private var title = ""
    @State private var location = ""
    @State private var rating = ""
    
    @State private var selectedImage: UIImage?
    @State private var selectedImageItem: PhotosPickerItem?
    
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Add New Destination")
                        .font(.title)
                        .bold()
                    
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Location", text: $location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Rating", text: $rating)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(Text("No image selected").foregroundColor(.gray))
                            .cornerRadius(10)
                    }
                    
                    PhotosPicker("Select Image", selection: $selectedImageItem, matching: .images)
                        .onChange(of: selectedImageItem) {
                            loadImage()
                        }

                    Button(action: uploadPost) {
                        if isUploading {
                            ProgressView()
                        } else {
                            Label("Upload Post", systemImage: "icloud.and.arrow.up")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("New Post", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Load UIImage from PhotosPickerItem
    private func loadImage() {
        guard let item = selectedImageItem else { return }
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                    } else {
                        self.alertMessage = "Failed to load image."
                        self.showAlert = true
                    }
                case .failure(let error):
                    self.alertMessage = "Image load error: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }

    // Upload post after checking all fields
    private func uploadPost() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              let ratingValue = Double(rating),
              !title.isEmpty, !location.isEmpty else {
            alertMessage = "Please fill all fields and select a valid image."
            showAlert = true
            return
        }

        isUploading = true
        postController.uploadPost(title: title, location: location, rating: ratingValue, imageData: imageData) { success in
            isUploading = false
            if success {
                alertMessage = "Post uploaded successfully!"
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                alertMessage = "Failed to upload post."
                showAlert = true
            }
        }
        print("Image: \(selectedImage != nil)")
        print("Rating: \(rating)")
        print("Title: \(title), Location: \(location)")

    }
}

struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView()
    }
}
