import SwiftUI
import WatchConnectivity

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

@MainActor
private final class WatchCourseListViewModel: NSObject, ObservableObject {
  @Published private(set) var rows: [WatchCourseRow] = []
  @Published private(set) var hasLoadedCache = false
  @Published private(set) var errorMessage: String?

  private let store = CourseCacheStore.live
  private let decoder = JSONDecoder.courseCache
  private let calendar = Calendar.autoupdatingCurrent
  private var showEnglishCourseName = AppSettings.defaultShowEnglishName()
  private var showEnglishTeacherName = AppSettings.defaultShowEnglishName()
  private var didStart = false

  func start() {
    guard !didStart else {
      return
    }

    didStart = true
    loadCachedCourses()
    activateSession()
  }

  private func loadCachedCourses() {
    do {
      guard let cache = try store.load() else {
        hasLoadedCache = false
        rows = []
        return
      }

      apply(cache: cache)
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func activateSession() {
    guard WCSession.isSupported() else {
      return
    }

    let session = WCSession.default
    session.delegate = self
    session.activate()
    apply(
      payloadData: session.receivedApplicationContext["coursePayload"] as? Data,
      cacheData: session.receivedApplicationContext["courseCache"] as? Data
    )
    requestLatestCoursesIfPossible(session)
  }

  private func requestLatestCoursesIfPossible(_ session: WCSession = .default) {
    guard session.activationState == .activated, session.isReachable else {
      return
    }

    session.sendMessage(["requestCourseCache": true], replyHandler: nil)
  }

  private func apply(payloadData: Data?, cacheData: Data?) {
    if let payloadData,
      let payload = try? decoder.decode(WatchCoursePayload.self, from: payloadData)
    {
      showEnglishCourseName = payload.showEnglishCourseName
      showEnglishTeacherName = payload.showEnglishTeacherName
      persistAndApply(cache: payload.cache)
      return
    }

    if let cacheData,
      let cache = try? decoder.decode(CourseCache.self, from: cacheData)
    {
      persistAndApply(cache: cache)
    }
  }

  private func persistAndApply(cache: CourseCache) {
    do {
      try store.save(cache)
      apply(cache: cache)
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func apply(cache: CourseCache) {
    hasLoadedCache = true
    errorMessage = nil
    rows = cache.courses
      .scheduledCourses(calendar: calendar)
      .map {
        WatchCourseRow(
          course: $0,
          showEnglishCourseName: showEnglishCourseName,
          showEnglishTeacherName: showEnglishTeacherName,
          calendar: calendar
        )
      }
  }
}

extension WatchCourseListViewModel: WCSessionDelegate {
  nonisolated func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    guard activationState == .activated else {
      return
    }

    Task { @MainActor in
      self.requestLatestCoursesIfPossible()
    }
  }

  nonisolated func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String: Any]
  ) {
    let payloadData = applicationContext["coursePayload"] as? Data
    let cacheData = applicationContext["courseCache"] as? Data

    Task { @MainActor in
      self.apply(payloadData: payloadData, cacheData: cacheData)
    }
  }
}

private struct WatchCourseRow: Identifiable {
  let id: String
  let weekdayText: String
  let timeText: String
  let courseName: String
  let teacherName: String
  let room: String

  init(
    course: ScheduledCourse,
    showEnglishCourseName: Bool,
    showEnglishTeacherName: Bool,
    calendar: Calendar
  ) {
    id = course.id
    weekdayText = Self.weekdayText(for: course.weekday, calendar: calendar)
    timeText = "\(Self.timeText(for: course.startTime))-\(Self.timeText(for: course.endTime))"
    courseName = course.displayName(showEnglish: showEnglishCourseName)
    teacherName = course.displayTeacher(showEnglish: showEnglishTeacherName)
    room = course.room
  }

  private static func weekdayText(for weekday: Int, calendar: Calendar) -> String {
    guard (1...7).contains(weekday) else {
      return ""
    }

    return calendar.shortWeekdaySymbols[(weekday % 7)]
  }

  private static func timeText(for date: Date) -> String {
    date.formatted(
      Date.FormatStyle.dateTime
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
    )
  }
}

#Preview {
  WatchCourseListView()
}
