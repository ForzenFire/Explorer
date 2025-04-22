import SwiftUI

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var selectedDate: Date? = Date()
    @State private var showCustomDatePicker = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Title", text: $title)
                        TextField("Notes", text: $notes)
                    }

                    Section {
                        HStack {
                            Text("Details")
                            Spacer()
                            Text(selectedDate.map { formattedDate($0) } ?? "None")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showCustomDatePicker.toggle()
                        }

                        HStack {
                            Text("List")
                            Spacer()
                            Text("Reminders")
                                .foregroundColor(.orange)
                        }
                    }

                    if showCustomDatePicker {
                        DatePicker("Select Date", selection: Binding($selectedDate)!, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                    }

                    Section {
                        HStack(spacing: 12) {
                            shortcutButton(label: "Today", days: 0)
                            shortcutButton(label: "Tomorrow", days: 1)
                            shortcutButton(label: "This Weekend", days: daysToWeekend())
                            shortcutButton(label: "Date & Time", custom: true)
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        ReminderManager.shared.addReminder(
                            reminderTitle: title,
                            notes: notes.isEmpty ? nil : notes,
                            dueDate: selectedDate,
                            list: "Reminders"
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedDate == nil)
                }
            }
        }
    }

    // MARK: - Helpers

    private func shortcutButton(label: String, days: Int? = nil, custom: Bool = false) -> some View {
        Button(action: {
            if custom {
                showCustomDatePicker = true
            } else if let days = days {
                selectedDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
                showCustomDatePicker = false
            }
        }) {
            Text(label)
                .font(.caption)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(selectedDateMatch(label) ? Color.blue : Color(.systemGray5))
                .foregroundColor(selectedDateMatch(label) ? .white : .black)
                .clipShape(Capsule())
        }
    }

    private func selectedDateMatch(_ label: String) -> Bool {
        guard let selected = selectedDate else { return false }
        let calendar = Calendar.current
        switch label {
            case "Today":
                return calendar.isDateInToday(selected)
            case "Tomorrow":
                return calendar.isDateInTomorrow(selected)
            case "This Weekend":
                return calendar.isDate(selected, equalTo: daysToWeekendDate(), toGranularity: .day)
            default:
                return false
        }
    }

    private func daysToWeekend() -> Int {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        // 1 = Sunday, 7 = Saturday
        let daysUntilSaturday = (7 - weekday + 7) % 7
        return daysUntilSaturday
    }

    private func daysToWeekendDate() -> Date {
        Calendar.current.date(byAdding: .day, value: daysToWeekend(), to: Date()) ?? Date()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView()
    }
}
