import Foundation
import MapKit
import Combine

class MapViewController: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
        span: MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
    )

    @Published var searchResults: [MapSearchResult] = []
    @Published var selectedPlace: MapSearchResult? = nil
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var route: MKRoute? = nil

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // 🔄 Update user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    // 🔍 Search for destination using natural language
    func search(_ query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let mapItems = response?.mapItems else { return }
            DispatchQueue.main.async {
                self.searchResults = mapItems.map { MapSearchResult(placemark: $0.placemark) }
            }
        }
    }

    // 🗺️ Generate route from current location to selected place
    func showDirections(to place: MapSearchResult) {
        selectedPlace = place

        guard let userLocation = userLocation else { return }

        let source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else { return }

            DispatchQueue.main.async {
                self.route = route
                self.region = MKCoordinateRegion(route.polyline.boundingMapRect)
            }
        }
    }
}
