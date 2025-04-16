import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isFABOpen = false
    @State private var showAddReminder = false
    @State private var showReminderList = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(0)

                MapView()
                    .tabItem { Label("Map", systemImage: "map") }
                    .tag(1)

                Color.clear // Placeholder for FAB
                    .tabItem { Label("", systemImage: "") }
                    .tag(2)

                MessageView()
                    .tabItem { Label("Message", systemImage: "message") }
                    .tag(3)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.circle") }
                    .tag(4)
            }

            GeometryReader { geo in
                VStack {
                    Spacer()
                    ZStack {
                        if isFABOpen {
                            // 📋 Reminder List
                            Button(action: {
                                isFABOpen = false
                                showReminderList = true
                            }) {
                                Image(systemName: "list.bullet.rectangle")
                                    .resizable()
                                    .frame(width: 26, height: 26)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            .offset(x: -60, y: -60)

                            // ✏️ Add Reminder
                            Button(action: {
                                isFABOpen = false
                                showAddReminder = true
                            }) {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            .offset(x: 60, y: -60)
                        }

                        // Main FAB
                        Button(action: {
                            withAnimation(.spring()) {
                                isFABOpen.toggle()
                            }
                        }) {
                            Image(systemName: isFABOpen ? "xmark" : "plus")
                                .resizable()
                                .frame(width: 26, height: 26)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 5)
                        }
                    }
                    .frame(width: geo.size.width)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showAddReminder) {
            AddReminderView()
        }
        .sheet(isPresented: $showReminderList) {
            ReminderView()
        }
    }
}
