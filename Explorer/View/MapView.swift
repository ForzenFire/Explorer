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
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Locations", text: $searchText, onCommit: {
                    viewController.search(searchText)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Map(coordinateRegion: $viewController.region,
                    showsUserLocation: true,
                    annotationItems: viewController.searchResults + (viewController.selectedPlace.map { [$0] } ?? [])) { place in MapMarker(coordinate: place.coordinate, tint: .blue)}
            }
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !viewController.searchResults.isEmpty {
                List(viewController.searchResults, id: \.id) { place in
                    Button(action: {
                        viewController.showDirections(to: place)
                    }) {
                        VStack(alignment: .leading) {
                            Text(place.name)
                            Text("\(place.coordinate.latitude), \(place.coordinate.longitude)")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }.frame(height: 200)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
