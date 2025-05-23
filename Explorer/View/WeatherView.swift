//
//  WeatherView.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-05-23.
//
import SwiftUI

struct WeatherView: View {
    @ObservedObject var weatherController: WeatherController

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(weatherController.temperature)
                    .font(.title2)
                    .bold()
                Text(weatherController.city)
                    .font(.subheadline)
            }

            Spacer()

            Image(systemName: weatherController.conditionIcon)
                .font(.system(size: 36))
        }
        .padding()
        .background(
            LinearGradient(colors: [.orange, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(25)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
