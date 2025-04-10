//
//  MapSearchResult.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-10.
//
import Foundation
import MapKit

struct MapSearchResult: Identifiable {
    let id = UUID()
    let placemark: MKPlacemark
    
    var name: String {
        placemark.name ?? "Unknown"
    }
    
    var coordinate: CLLocationCoordinate2D {
        placemark.coordinate
    }
}
