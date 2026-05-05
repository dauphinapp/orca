import Code39
import SwiftUI
import WidgetKit

struct StudentIDWidgetEntry: TimelineEntry {
  enum State {
    case signedOut
    case unavailable
    case ready(studentID: String)
  }

  let date: Date
  let state: State
}

struct StudentIDWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> StudentIDWidgetEntry {
    StudentIDWidgetPreviewData.ready
  }

  func getSnapshot(in context: Context, completion: @escaping (StudentIDWidgetEntry) -> Void) {
    completion(makeEntry(now: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<StudentIDWidgetEntry>) -> Void) {
    completion(Timeline(entries: [makeEntry(now: Date())], policy: .never))
  }

  private func makeEntry(now: Date) -> StudentIDWidgetEntry {
    if !AppSettings.hasActiveWidgetSession() {
      return StudentIDWidgetEntry(date: now, state: .signedOut)
    }

    let record = try? StudentIDStore.live.load()
    guard let record, !record.studentID.isEmpty else {
      return StudentIDWidgetEntry(date: now, state: .unavailable)
    }

    return StudentIDWidgetEntry(date: now, state: .ready(studentID: record.studentID))
  }
}

struct StudentIDWidget: Widget {
  let kind = "StudentIDWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: StudentIDWidgetProvider()) { entry in
      StudentIDWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Student ID")
    .description("Show your student ID as a Code 39 barcode.")
    .supportedFamilies([.systemMedium])
  }
}

private struct StudentIDWidgetEntryView: View {
  let entry: StudentIDWidgetEntry

  var body: some View {
    Group {
      switch entry.state {
      case .signedOut:
        messageView(
          icon: "person.badge.key.fill",
          title: "Sign in to show your student ID",
          detail: "Open Dauphin and sign in once."
        )

      case .unavailable:
        messageView(
          icon: "barcode.viewfinder",
          title: "Student ID unavailable",
          detail: "Refresh the app to sync your barcode."
        )

      case .ready(let studentID):
        readyView(studentID: studentID)
      }
    }
    .containerBackground(for: .widget) {
      Color.white
    }
  }

  private func messageView(icon: String, title: String, detail: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 28, weight: .semibold))
        .foregroundStyle(Color.blue)

      VStack(alignment: .leading, spacing: 6) {
        Text(title)
          .font(.system(size: 19, weight: .bold, design: .rounded))
          .foregroundStyle(.primary)

        Text(detail)
          .font(.system(size: 13, weight: .medium, design: .rounded))
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding(18)
  }

  private func readyView(studentID: String) -> some View {
    VStack(spacing: 10) {
      Spacer(minLength: 0)
      Code39View(studentID)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(.horizontal, 4)

      Text(studentID)
        .font(.system(size: 12))
        .frame(maxWidth: .infinity, alignment: .center)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.horizontal, 18)
    .padding(.vertical, 14)
  }
}

#Preview("Student ID / Medium", as: .systemMedium) {
  StudentIDWidget()
} timeline: {
  StudentIDWidgetPreviewData.signedOut
  StudentIDWidgetPreviewData.unavailable
  StudentIDWidgetPreviewData.ready
}
