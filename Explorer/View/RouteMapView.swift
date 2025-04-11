//
//  RouteMapView.swift
//  Explorer
//
//  Created by KAVINDU 040 on 2025-04-11.
//
import SwiftUI
import MapKit

struct RouteMapView: UIViewRepresentable {
    @ObservedObject var viewController: MapViewController

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(viewController.region, animated: true)

        // Remove old pins
        mapView.removeAnnotations(mapView.annotations)

        // Add search result annotations
        for place in viewController.searchResults {
            let annotation = MKPointAnnotation()
            annotation.coordinate = place.coordinate
            annotation.title = place.name
            mapView.addAnnotation(annotation)
        }

        // Remove and draw route
        mapView.removeOverlays(mapView.overlays)
        if let route = viewController.route {
            mapView.addOverlay(route.polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
