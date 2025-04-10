//
//  MainTabView.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-09.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem{Label("Home", systemImage: "house")}
                    .tag(0)
                MapView()
                    .tabItem{Label("Map", systemImage: "map")}
                    .tag(1)
                ReminderView()
                    .tabItem {Label("", systemImage: "")}
                    .tag(2)
                MessageView()
                    .tabItem{Label("Message", systemImage: "message")}
                    .tag(3)
                ProfileView()
                    .tabItem{Label("Profile", systemImage: "person.circle")}
                    .tag(4)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        selectedTab = 2
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, UIScreen.main.bounds.width / 2-30)
                }
            }
        }
    }
}
