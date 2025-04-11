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
    @State private var searchText = ""
    @State private var showDrawer = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // 🗺️ Custom map with pins + route
            RouteMapView(viewController: viewController)
                .edgesIgnoringSafeArea(.all)

            // 🔍 Search bar at bottom
            VStack(spacing: 12) {
                HStack {
                    TextField("Search destination", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    Button(action: {
                        viewController.search(searchText)
//                        showDrawer = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    showDrawer.toggle()
                }) {
                    Capsule()
                        .fill(Color.secondary)
                        .frame(width: 100, height: 5)
                        .padding(.top, 8)
                }
                .zIndex(1)
            }
            .padding(.bottom, 20)

            // 📍 Search Results List + Direction Button
            if !viewController.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewController.searchResults, id: \.id) { place in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(place.name)
                                        .font(.headline)
                                }}
                        }
                    }
                    List(viewController.searchResults, id: \.id) { place in
                        VStack(alignment: .leading) {
                            Text(place.name)
                                .font(.headline)

                            Text("\(place.coordinate.latitude), \(place.coordinate.longitude)")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Button("Directions") {
                                viewController.showDirections(to: place)
                                showDrawer = false
                            }
                            .font(.subheadline)
                            .padding(6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(height: 220)

                    // 🧭 Clear Route Button
                    if viewController.route != nil {
                        Button("Clear Route") {
                            viewController.route = nil
                            if let loc = viewController.userLocation {
                                viewController.region = MKCoordinateRegion(
                                    center: loc,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            }
                        }
                        .font(.subheadline)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom, 90)
            }
        }
        .sheet(isPresented: $showDrawer) {
            BottomSheetContent(viewController: viewController)
        }
    }
}

struct BottomSheetContent: View {
    @ObservedObject var viewController: MapViewController

    var body: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Text("Siri Suggestions")
                .font(.headline)
                .padding(.top)

            List {
                Button("Nuwara Eliya") {
                    viewController.search("Nuwara Eliya")
                }
                Button("Sigiriya Rock") {
                    viewController.search("Sigiriya")
                }
            }

            Text("Favorites")
                .font(.headline)
                .padding(.top)

            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Image(systemName: "plus.circle")
                    Text("Add")
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
