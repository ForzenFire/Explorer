//
//  ContentView.swift
//  Explorer
//
//  Created by KAVINDU 040 on 2025-03-29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Explore Map")
                .font(.title)
                .padding()
            
            MapViewRepresentable()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ContentView()
}
