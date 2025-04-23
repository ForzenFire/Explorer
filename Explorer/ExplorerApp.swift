//
//  ExplorerApp.swift
//  Explorer
//
//  Created by KAVINDU 040 on 2025-03-29.
//

import SwiftUI
import FirebaseCore
import EventKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("Firebase Configured!")
    
      requestPermissions()
      UNUserNotificationCenter.current().delegate = self
    
    return true
  }
    
    private func requestPermissions() {
        let eventStore = EKEventStore()

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                if granted {
                    print("✅ Full Reminder access granted (iOS 17+)")
                } else {
                    print("❌ Access denied: \(String(describing: error))")
                }
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                if granted {
                    print("✅ Reminder access granted (iOS <17)")
                } else {
                    print("❌ Access denied: \(String(describing: error))")
                }
            }
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification access granted.")
            } else {
                print("❌ Notification permission denied: \(String(describing: error))")
            }
        }
    }
    
    // ✅ Display banners while app is in foreground
    @objc(userNotificationCenter:willPresentNotification:withCompletionHandler:)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct ExplorerApp: App {
    //Registering the app to Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
