import Foundation
import CoreData
import EventKit
import UserNotifications
import SwiftUI

final class ReminderManager: ObservableObject {
    static let shared = ReminderManager()

    private let context = PersistenceController.shared.container.viewContext
    private let eventStore = EKEventStore()
    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    func addReminder(reminderTitle: String, notes: String?, dueDate: Date?, list: String?, onFailure: @escaping () -> Void = {}) {
        let reminder = Explorer.CDReminder(context: context)
        reminder.title = reminderTitle
        reminder.notes = notes
        reminder.dueDate = dueDate
        reminder.list = list
        reminder.createdAt = Date()
        reminder.uuid = UUID().uuidString

        saveContext()
        addToEventKit(reminder, onFailure: onFailure)
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

    func saveChanges(for reminder: CDReminder) {
        saveContext()
        updateEventKitReminder(for: reminder)
        print("Reminder updated.")
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save context:", error.localizedDescription)
        }
    }

    private func addToEventKit(_ reminder: CDReminder, onFailure: @escaping () -> Void) {
        let permissionHandler: (Bool, Error?) -> Void = { granted, error in
            DispatchQueue.main.async {
                guard granted else {
                    print("Reminder access denied: \(String(describing: error))")
                    onFailure()
                    return
                }
                self.saveEKReminder(for: reminder, onFailure: onFailure)
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders(completion: permissionHandler)
        } else {
            eventStore.requestAccess(to: .reminder, completion: permissionHandler)
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
                [.year, .month, .day, .hour], from: date
            )
        }
        
        if let calendar = self.eventStore.defaultCalendarForNewReminders() {
            ekReminder.calendar = calendar
        } else if let fallback = self.eventStore.calendars(for: .reminder).first(where: { $0.allowsContentModifications}) {
            ekReminder.calendar = fallback
        } else {
            print("No writable calendar found for reminders.")
            DispatchQueue.main.async {
                onFailure?()
            }
            return
        }
        
        do {
            try self.eventStore.save(ekReminder, commit: true)
            print("Rmeinder saved to system Reminders app")
            
            DispatchQueue.main.async {
                reminder.calendarIdentifier = ekReminder.calendarItemIdentifier
                self.saveContext()
                print("calenderIdentifier saved: \(reminder.calendarIdentifier ?? "nil")")
            }
        } catch {
            print("Failed to save to EventKit: \(error.localizedDescription)")
        }
    }

    private func updateEventKitReminder(for reminder: CDReminder) {
        guard let uuid = reminder.uuid else { return }

        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { reminders in
            guard let existing = reminders?.first(where: { $0.notes?.contains("[uuid:\(uuid)]") == true }) else {
                print("No matching EventKit reminder found to update.")
                return
            }

            DispatchQueue.main.async {
                existing.title = reminder.title ?? ""
                existing.notes = "[uuid:\(uuid)]\n\(reminder.notes ?? "")"
                if let date = reminder.dueDate {
                    //First Removing any existing alarms
                    existing.alarms?.forEach { existing.removeAlarm($0) }
                    
                    //Adding a new alarm
                    let alarm = EKAlarm(absoluteDate: date)
                    existing.addAlarm(alarm)
                    
                    //Set due date component
                    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    existing.dueDateComponents = components
                    print("Updating due date to: \(components)")
//                    existing.alarms = [EKAlarm(absoluteDate: date)]
//                    existing.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                }

                do {
                    try self.eventStore.save(existing, commit: true)
                    print("Updated EventKit reminder.")
                } catch {
                    print("Failed to update EventKit reminder:", error.localizedDescription)
                }
            }
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

        notificationCenter.add(request) { error in
            if let error = error {
                print("Notification scheduling failed:", error.localizedDescription)
            } else {
                print("Notification scheduled for:", uuid)
            }
        }
    }

    private func cancelNotification(uuid: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
    }

    func checkReminderPermissionStatus() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .notDetermined: print("Not determined")
        case .restricted: print("Restricted")
        case .denied: print("Denied")
        case .authorized: print("Authorized")
        case .fullAccess: print("Full access granted")
        case .writeOnly: print("Write-only access")
        @unknown default: print("Unknown authorization status")
        }
    }
}
