import SwiftUI

struct WatchCourseListView: View {
  @StateObject private var viewModel = WatchCourseListViewModel()

  var body: some View {
    NavigationStack {
      Group {
        if let errorMessage = viewModel.errorMessage {
          ContentUnavailableView("Unable to Load", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
        } else if !viewModel.hasLoadedCache {
          ContentUnavailableView("No Courses Synced", systemImage: "iphone.and.arrow.forward", description: Text("Open Dauphin on iPhone to sync courses."))
        } else if viewModel.rows.isEmpty {
          ContentUnavailableView("No Courses This Week", systemImage: "calendar.badge.exclamationmark")
        } else {
          List(viewModel.rows) { row in
            VStack(alignment: .leading, spacing: 4) {
              HStack(alignment: .firstTextBaseline) {
                Text(row.weekdayText)
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                Spacer(minLength: 6)
                Text(row.timeText)
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                  .monospacedDigit()
              }

              Text(row.courseName)
                .font(.headline)
                .lineLimit(2)

              if !row.teacherName.isEmpty {
                Text(row.teacherName)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
              }

              if !row.room.isEmpty {
                Label(row.room, systemImage: "location.fill")
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
              }
            }
            .padding(.vertical, 3)
          }
        }
      }
      .navigationTitle("Courses")
    }
    .task {
      viewModel.start()
    }
  }
}

#Preview {
  WatchCourseListView()
}
