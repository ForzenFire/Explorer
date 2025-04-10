//
//  MessageView.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-09.
//
import SwiftUI

struct MessageView: View {
    var body: some View {
        NavigationView {
            Text("Message")
                .navigationTitle("Message")
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
