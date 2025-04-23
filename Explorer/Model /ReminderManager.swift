import Foundation
import CoreData
import EventKit
import UserNotifications
import SwiftUI

//typealias CDReminder = Reminder

final class ReminderManager: ObservableObject {
    static let shared = ReminderManager()

    private let context = PersistenceController.shared.container.viewContext
    private let eventStore = EKEventStore()
    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    func addReminder(reminderTitle: String, notes: String?, dueDate: Date?, list: String?, onFailure: (() -> Void)? = nil) {
        let reminder = Explorer.CDReminder(context: context)

        reminder.title = reminderTitle
        reminder.notes = notes
        reminder.dueDate = dueDate
        reminder.list = list
        reminder.createdAt = Date()
        reminder.uuid = UUID().uuidString

        saveContext()
        addToEventKit(reminder)
        scheduleNotification(for: reminder)
    }

    func getReminders() -> [CDReminder] {
        let request: NSFetchRequest<CDReminder> = CDReminder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func deleteReminder(_ reminder: CDReminder) {
        if let uuid = reminder.uuid {
            cancelNotification(uuid: uuid)
        }
        context.delete(reminder)
        saveContext()
    }

    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }

    //Add reminders to system
    private func addToEventKit(_ reminder: CDReminder, onFailure: (() -> Void)? = nil) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                guard granted else {
                    print("❌ Full reminder access denied (iOS 17+): \(String(describing: error))")
                    return
                }
                self.saveEKReminder(for: reminder)
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                guard granted else {
                    print("❌ Reminder access denied (iOS <17): \(String(describing: error))")
                    return
                }
                self.saveEKReminder(for: reminder)
            }
        }
    }
    
    private func saveEKReminder(for reminder: CDReminder, onFailure: (() -> Void)? = nil) {
        let ekReminder = EKReminder(eventStore: self.eventStore)
        ekReminder.title = reminder.title ?? ""
        ekReminder.notes = reminder.notes

        if let date = reminder.dueDate {
            let alarm = EKAlarm(absoluteDate: date)
            ekReminder.addAlarm(alarm)
            ekReminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: date
            )
        }

        // ✅ Assign to default calendar, fallback if nil
        if let calendar = self.eventStore.defaultCalendarForNewReminders() {
            ekReminder.calendar = calendar
        } else if let fallback = self.eventStore.calendars(for: .reminder).first(where: { $0.allowsContentModifications }) {
            ekReminder.calendar = fallback
        } else {
            print("❌ No writable calendar found for reminders.")
            DispatchQueue.main.async {
                onFailure?()
            }
            return
        }

        do {
            try self.eventStore.save(ekReminder, commit: true)
            print("✅ Reminder saved to system Reminders app")
        } catch {
            print("❌ Failed to save to EventKit: \(error.localizedDescription)")
        }
    }


    private func scheduleNotification(for reminder: CDReminder) {
        guard let uuid = reminder.uuid, let title = reminder.title, let date = reminder.dueDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)

        print("📅 Scheduling notification at:", date)

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Notification failed:", error.localizedDescription)
            } else {
                print("✅ Notification scheduled for:", uuid)
            }
        }
    }


    private func cancelNotification(uuid: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
    }
    
    func checkReminderPermissionStatus() {
        
        let status = EKEventStore.authorizationStatus(for: .reminder)

        switch status {
        case .notDetermined:
            print("🔍 Not determined")
        case .restricted:
            print("🚫 Restricted")
        case .denied:
            print("❌ Denied")
        case .authorized:
            print("✅ Authorized")
        case .fullAccess:
            print("✅ Full access granted")
        case .writeOnly:
            print("✍️ Write-only access")
        @unknown default:
            print("❓ Unknown status")
        }

    }
}
