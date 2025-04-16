import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewController = MapViewController()
    @State private var panelPosition: PanelPosition = .middle
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var lastNonKeyboardPosition: PanelPosition = .middle
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map View
            RouteMapView(viewController: viewController)
                .edgesIgnoringSafeArea(.all)
            
            // Bottom Panel
            SwipePanel(position: $panelPosition, isKeyboardActive: isSearchFieldFocused) {
                VStack(spacing: 12) {
                    searchBar
                    Divider()
                    resultsList
                }
                .padding(.bottom)
            }
        }
        .onChange(of: isSearchFieldFocused) { focused in
            withAnimation(.interactiveSpring()) {
                if focused {
                    lastNonKeyboardPosition = panelPosition
                    panelPosition = .bottom
                } else {
                    panelPosition = lastNonKeyboardPosition
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            TextField("Search location...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit(performSearch)
                .onTapGesture {
                    lastNonKeyboardPosition = panelPosition
                    panelPosition = .bottom
                }
            
            Button(action: performSearch) {
                Text("Search")
            }
            .buttonStyle(.borderedProminent)
            .disabled(searchText.isEmpty)
        }
        .padding(.horizontal)
    }
    
    private var resultsList: some View {
        Group {
            if !viewController.searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewController.searchResults, id: \.id) { place in
                            placeButton(for: place)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
            } else {
                emptyStateView
            }
        }
    }
    
    private func placeButton(for place: MapSearchResult) -> some View {
        Button(action: { selectPlace(place) }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.headline)
                    if let address = place.placemark.title {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text(searchText.isEmpty ? "Search for locations" : "No results found")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func performSearch() {
        viewController.search(searchText)
        hideKeyboard()
    }
    
    private func selectPlace(_ place: MapSearchResult) {
        // Force hide keyboard first
        isSearchFieldFocused = false
        hideKeyboard()
        
        // Then select the place after a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewController.showDirections(to: place)
            panelPosition = .middle
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
