import Foundation
import MapKit
import Combine

extension MKCoordinateRegion {
    static func regionForMapRect(_ mapRect: MKMapRect, padding: UIEdgeInsets) -> MKCoordinateRegion {
        let tempMapView = MKMapView()
        let fittedRect = tempMapView.mapRectThatFits(mapRect, edgePadding: padding)
        return MKCoordinateRegion(fittedRect)
    }
}

class MapViewController: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
        span: MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
    )
    
    @Published var searchResults: [MapSearchResult] = []
    @Published var selectedPlace: MapSearchResult?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var route: MKRoute?
    @Published var isNavigatingToSearchResult = false
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            if !self.isNavigatingToSearchResult {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    func search(_ query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        MKLocalSearch(request: request).start { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    self?.searchResults = []
                    return
                }
                
                self?.searchResults = response?.mapItems.map {
                    MapSearchResult(placemark: $0.placemark)
                } ?? []
            }
        }
    }
    
    func showDirections(to place: MapSearchResult) {
        isNavigatingToSearchResult = true
        selectedPlace = place
        region = MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        guard let userLocation = userLocation else {
            print("Showing place without directions - User location not available")
            return
        }
        
        guard CLLocationCoordinate2DIsValid(userLocation) &&
                CLLocationCoordinate2DIsValid(place.coordinate) else {
            print("Invalid coordinates for routing")
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
        request.transportType = .automobile
        
        MKDirections(request: request).calculate { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Directions error: \(error.localizedDescription)")
                    self?.route = nil
                    self?.region = MKCoordinateRegion(
                        center: place.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    return
                }
                
                guard let route = response?.routes.first else {
                    print("No routes found - showing destination only")
                    self?.route = nil
                    return
                }
                
                self?.route = route
                let routeRect = route.polyline.boundingMapRect
                let padding = UIEdgeInsets(top: 50, left: 50, bottom: 100, right: 50)
                self?.region = MKCoordinateRegion.regionForMapRect(routeRect, padding: padding)
            }
        }
    }
}
