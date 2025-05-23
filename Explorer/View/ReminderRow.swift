import SwiftUI

struct ReminderRow: View {
    @ObservedObject var reminder: CDReminder
    let onDelete: () -> Void
    let onToggleCompletion: (Bool) -> Void

    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                let newStatus = !reminder.isCompleted
                onToggleCompletion(newStatus)
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(reminder.isCompleted ? .blue : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title ?? "")
                    .font(.body)
                    .strikethrough(reminder.isCompleted, color: .gray)
                    .foregroundColor(reminder.isCompleted ? .gray : .primary)

                if let list = reminder.list {
                    HStack(spacing: 6) {
                        Circle().fill(.red).frame(width: 10, height: 10)
                        Text(list)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
