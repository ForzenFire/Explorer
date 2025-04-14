//
//  BottomSheetDrawer.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-14.
//
import SwiftUI
import MapKit

struct BottomSheetDrawer: View {
    @ObservedObject var viewController: MapViewController
    @Binding var searchText: String

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            // MARK: - Search Field
            HStack {
                TextField("Search destination", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                Button(action: {
                    viewController.search(searchText)
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            // MARK: - Search Results
            if !viewController.searchResults.isEmpty {
                List(viewController.searchResults, id: \.id) { place in
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.headline)

                        Text("\(place.coordinate.latitude), \(place.coordinate.longitude)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Button("Directions") {
                            viewController.showDirections(to: place)
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
            }

            // MARK: - Clear Route
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

            // MARK: - Favorites
            HStack(spacing: 20) {
                Button(action: { viewController.search("Home") }) {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: { viewController.search("Work") }) {
                    VStack {
                        Image(systemName: "briefcase.fill")
                        Text("Work")
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: { viewController.search("Add") }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
        .presentationDetents([.fraction(0.2), .medium, .large])
    }
}
