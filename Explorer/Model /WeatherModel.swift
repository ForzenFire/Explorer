//
//  WeatherModel.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-05-23.
//
import Foundation
import CoreLocation

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let name: String
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
