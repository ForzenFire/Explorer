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
        reminder.isCompleted = false // ✅ default value
        
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
        deleteFromEventKit(eventIdentifier: reminder.eventIdentifier)
        context.delete(reminder)
        saveContext()
    }
    
    private func deleteFromEventKit(eventIdentifier: String?) {
        guard let eventIdentifier = eventIdentifier else { return }
        
        if let ekReminder = eventStore.calendarItem(withIdentifier: eventIdentifier) as? EKReminder {
            do {
                try eventStore.remove(ekReminder, commit: true)
                print("🗑️ Deleted reminder from EventKit.")
            } catch {
                print("❌ Failed to delete reminder from EventKit:", error.localizedDescription)
            }
        } else {
            print("❌ No matching EventKit reminder found.")
        }
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
        
        let uuidTag = "[uuid:\(reminder.uuid ?? "")]"
        let combinedNotes = (reminder.notes?.isEmpty ?? true) ? uuidTag : "\(uuidTag)\n\(reminder.notes!)"
        ekReminder.notes = combinedNotes
        
        if let date = reminder.dueDate {
            let alarm = EKAlarm(absoluteDate: date)
            ekReminder.addAlarm(alarm)
            ekReminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: date
            )
        }
        
        if let calendar = eventStore.defaultCalendarForNewReminders() {
            ekReminder.calendar = calendar
        } else if let fallback = eventStore.calendars(for: .reminder).first(where: { $0.allowsContentModifications }) {
            ekReminder.calendar = fallback
        } else {
            print("No writable calendar found.")
            DispatchQueue.main.async { onFailure?() }
            return
        }
        
        do {
            try eventStore.save(ekReminder, commit: true)
            DispatchQueue.main.async {
                reminder.eventIdentifier = ekReminder.calendarItemIdentifier
                self.saveContext()
                print("eventIdentifier saved: \(reminder.eventIdentifier ?? "nil")")
            }
        } catch {
            print("Failed to save to EventKit: \(error.localizedDescription)")
        }
    }
    
    private func updateEventKitReminder(for reminder: CDReminder) {
        guard let eventIdentifier = reminder.eventIdentifier else {
            print("No eventIdentifier for this reminder")
            return
        }
        
        if let existing = eventStore.calendarItem(withIdentifier: eventIdentifier) as? EKReminder {
            existing.title = reminder.title ?? ""
            let uuidTag = "[uuid:\(reminder.uuid ?? "")]"
            existing.notes = (reminder.notes?.isEmpty ?? true) ? uuidTag : "\(uuidTag)\n\(reminder.notes!)"
            
            if let date = reminder.dueDate {
                existing.alarms?.forEach { existing.removeAlarm($0) }
                let alarm = EKAlarm(absoluteDate: date)
                existing.addAlarm(alarm)
                existing.dueDateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute], from: date
                )
            }
            
            do {
                try eventStore.save(existing, commit: true)
                print("✅ Updated EventKit reminder.")
            } catch {
                print("❌ Failed to update EventKit reminder:", error.localizedDescription)
            }
        } else {
            print("❌ EventKit reminder not found.")
        }
    }
    
    private func scheduleNotification(for reminder: CDReminder) {
        guard let uuid = reminder.uuid, let title = reminder.title, let date = reminder.dueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = title
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: date
        )
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
    
    func updateCompletionStatus(for reminder: CDReminder, to status: Bool) {
        reminder.isCompleted = status
        saveContext()
        print("✅ Core Data isCompleted updated.")
    }
    
    func toggleCompletion(for reminder: CDReminder, isCompleted: Bool) {
        guard let identifier = reminder.eventIdentifier else {
            print("❌ No eventIdentifier to complete reminder.")
            return
        }
        
        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted else {
                print("Access to reminders not granted")
                return
            }
            
            if let ekReminder = self.eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
                ekReminder.isCompleted = isCompleted
                do {
                    try self.eventStore.save(ekReminder, commit: true)
                    print("EventKit reminder completion updated.")
                } catch {
                    print("Failed to update reminder completion: \(error.localizedDescription)")
                }
            } else {
                print("Reminder not found in EventKit")
            }
        }
        
        // ✅ Update Core Data completion status
        DispatchQueue.main.async {
            self.updateCompletionStatus(for: reminder, to: isCompleted)
        }
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
        @unknown default: print("Unknown status")
        }
    }
}
