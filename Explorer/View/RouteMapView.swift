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

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(viewController.region, animated: true)

        uiView.removeAnnotations(uiView.annotations)
        let annotations = viewController.searchResults.map { result in
            let annotation = MKPointAnnotation()
            annotation.coordinate = result.coordinate
            annotation.title = result.name
            return annotation
        }
        uiView.addAnnotations(annotations)

        uiView.removeOverlays(uiView.overlays)
        if let route = viewController.route {
            uiView.addOverlay(route.polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView

        init(_ parent: RouteMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

