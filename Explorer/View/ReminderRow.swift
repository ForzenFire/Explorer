import SwiftUI

struct ReminderRow: View {
    let reminder: CDReminder
    let onDelete: () -> Void
    @State private var isCompleted = false

    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                isCompleted.toggle()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .blue : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title ?? "")
                    .font(.body)
                if let list = reminder.list {
                    HStack(spacing: 6) {
                        Circle().fill(.red).frame(width: 10, height: 10)
                        Text(list)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
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
