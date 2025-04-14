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

           
        }
        .presentationDetents([.medium, .large])
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
