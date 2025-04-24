import SwiftUI
import FirebaseCore
import EventKit
import UserNotifications
import Firebase
import FirebaseAuth

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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isLoggedIn: Bool = false
    @State private var checkedAuth: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if checkedAuth {
                    if isLoggedIn {
                        MainTabView()
                            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("logout"))) { _ in
                                isLoggedIn = false
                            }
                    } else {
                        LoginView()
                            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("login"))) { _ in
                                isLoggedIn = true
                            }
                    }
                } else {
                    // Optional: splash screen or progress indicator
                    ProgressView("Loading...")
                }
            }
            .onAppear {
                // Delay Auth check until Firebase is configured
                DispatchQueue.main.async {
                    isLoggedIn = Auth.auth().currentUser != nil
                    checkedAuth = true
                }
            }
        }
    }
}
