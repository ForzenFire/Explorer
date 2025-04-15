//
//  MapView.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-04.
//
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewController = MapViewController()
    @State private var panelPosition: PanelPosition = .middle
    @State private var searchText = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            // 🗺️ Custom map with pins + route
            RouteMapView(viewController: viewController)
                .edgesIgnoringSafeArea(.all)

            // In MapView.swift (inside SwipePanel content)
            SwipePanel(position: $panelPosition) {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("Search location...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                        Button("Search") {
                            viewController.search(searchText) // ← calls correct function
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)

                    Divider()

                    // Dynamic content: show results if available
                    if !viewController.searchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 4) {
                                ForEach(viewController.searchResults, id: \.id) { place in
                                    Button(action: {
                                        viewController.showDirections(to: place)
                                        panelPosition = .bottom // Optionally collapse panel
                                    }) {
                                        Text(place.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(8)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    } else {
                        Text("No results").foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 16) // Removes extra space under text field
            }

        }
//        .presentationDetents([.medium, .large])
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
