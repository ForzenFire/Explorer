import SwiftUI
import EventKit

struct EditReminderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var reminder: CDReminder
    var onSave: () -> Void

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedDate: Date?

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
        reminder.title = title
        reminder.notes = notes.isEmpty ? nil : notes
        reminder.dueDate = selectedDate

        ReminderManager.shared.saveChanges(for: reminder)

        onSave()
        dismiss()
    }
}
