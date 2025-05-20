import SwiftUI
import EventKit

struct EditReminderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var reminder: CDReminder
    var onSave: () -> Void

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedDate: Date?

    private let eventStore = EKEventStore()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $title)
                }

                Section(header: Text("Notes")) {
                    TextField("Notes", text: $notes)
                }

                Section(header: Text("Due Date")) {
                    DatePicker("Select Date", selection: Binding(get: {
                        selectedDate ?? Date()
                    }, set: {
                        selectedDate = $0
                    }), displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                }
            }
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear(perform: loadExistingData)
        }
    }

    private func loadExistingData() {
        title = reminder.title ?? ""
        notes = reminder.notes ?? ""
        selectedDate = reminder.dueDate ?? Date()
    }

    private func saveChanges() {
        // 1. Update local Core Data reminder
        reminder.title = title
        reminder.notes = notes.isEmpty ? nil : notes
        reminder.dueDate = selectedDate

        // 2. Try to update system EKReminder
        if let ekReminderID = reminder.calendarIdentifier {
            if let ekReminder = eventStore.calendarItem(withIdentifier: ekReminderID) as? EKReminder {
                ekReminder.title = title
                ekReminder.notes = notes
                if let selectedDate {
                    ekReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
                }

                do {
                    try eventStore.save(ekReminder, commit: true)
                } catch {
                    print("❌ Failed to update EKReminder: \(error.localizedDescription)")
                }
            } else {
                print("⚠️ Could not find EKReminder with identifier: \(ekReminderID)")
            }
        } else {
            print("⚠️ No calendarIdentifier found on CDReminder")
        }


        // 3. Save local context
        ReminderManager.shared.saveChanges(for: reminder)
        onSave()
        dismiss()
    }
}
