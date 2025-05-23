//
//  WeatherController.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-05-23.
//
import Foundation
import CoreLocation
import Combine

class WeatherController: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var temperature: String = "--"
    @Published var city: String = "Fetching..."
    @Published var conditionIcon: String = "cloud"

    private let locationManager = CLLocationManager()
    private let apiKey = "b0faef347a018b051f51ad337ff986f9" // OpenWeatherMap key

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
    }

    func fetchWeather(lat: Double, lon: Double) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlStr) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            if let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.temperature = "\(Int(weatherResponse.main.temp))°C"
                    self.city = weatherResponse.name
                    self.conditionIcon = self.mapIcon(to: weatherResponse.weather.first?.icon ?? "")
                }
            }
        }.resume()
    }

    private func mapIcon(to iconCode: String) -> String {
        switch iconCode {
        case "01d": return "sun.max"
        case "01n": return "moon"
        case "02d", "02n": return "cloud.sun"
        case "03d", "03n": return "cloud"
        case "09d", "09n": return "cloud.drizzle"
        case "10d", "10n": return "cloud.sun.rain"
        case "11d", "11n": return "cloud.bolt"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog"
        default: return "cloud"
        }
    }
}
