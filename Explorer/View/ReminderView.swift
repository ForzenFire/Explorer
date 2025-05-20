import EventKit
import SwiftUI

struct ReminderView: View {
    @State private var reminders: [CDReminder] = []
    @State private var showEditSheet = false
    @State private var selectedReminder: CDReminder?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    Section(header: reminderHeader(title: "Today", systemImage: "calendar")) {
                        ForEach(reminders.filter(isToday), id: \ .uuid) { reminder in
                            ReminderRow(reminder: reminder) {
                                delete(reminder: reminder)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Edit") {
                                    selectedReminder = reminder
                                    showEditSheet = true
                                }
                                .tint(.orange)
                            }
                        }
                    }

                    Section(header: reminderHeader(title: "Scheduled", systemImage: "calendar.badge.clock")) {
                        ForEach(reminders.filter(isUpcoming), id: \ .uuid) { reminder in
                            ReminderRow(reminder: reminder) {
                                delete(reminder: reminder)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Edit") {
                                    selectedReminder = reminder
                                    showEditSheet = true
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .onAppear {
                    loadReminders()
                }
                .sheet(item: $selectedReminder) { reminder in
                    EditReminderView(reminder: reminder) {
                        loadReminders()
                    }
                }

                Button(action: {
                    // TODO: Present AddReminderView
                }) {
                    Text("New Reminder")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .navigationTitle("Reminder")
        }
    }

    private func loadReminders() {
        reminders = ReminderManager.shared.getReminders()
    }

    private func delete(reminder: CDReminder) {
        ReminderManager.shared.deleteReminder(reminder)
        reminders.removeAll { $0.uuid == reminder.uuid }
    }

    private func isToday(_ reminder: CDReminder) -> Bool {
        guard let date = reminder.dueDate else { return false }
        return Calendar.current.isDateInToday(date)
    }

    private func isUpcoming(_ reminder: CDReminder) -> Bool {
        guard let date = reminder.dueDate else { return false }
        return date > Date() && !Calendar.current.isDateInToday(date)
    }

    private func reminderHeader(title: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
        }
    }
}
