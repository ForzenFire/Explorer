//
//  HomeView.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-09.
//
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            Text("Home")
                .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
