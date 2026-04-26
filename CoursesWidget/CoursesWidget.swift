import Foundation
import SwiftUI
import WidgetKit

struct CoursesWidgetEntry: TimelineEntry {
  let date: Date
  let isLoggedIn: Bool
  let upcomingCourses: [UpcomingScheduledCourse]
  let todayCount: Int
  let showEnglishCourseName: Bool
  let showEnglishTeacherName: Bool
}

struct CoursesWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> CoursesWidgetEntry {
    CoursesWidgetEntry(
      date: Date(),
      isLoggedIn: true,
      upcomingCourses: previewUpcomingCourses,
      todayCount: 2,
      showEnglishCourseName: false,
      showEnglishTeacherName: false
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (CoursesWidgetEntry) -> Void) {
    completion(makeEntry(now: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CoursesWidgetEntry>) -> Void) {
    let now = Date()
    let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: now) ?? now.addingTimeInterval(900)
    let entry = makeEntry(now: now)
    completion(Timeline(entries: [entry], policy: .after(refreshDate)))
  }

  private func makeEntry(now: Date) -> CoursesWidgetEntry {
    let cache = loadCourseCache()
    let scheduledCourses = cache?.courses.scheduledCourses() ?? []
    let resolver = UpcomingScheduledCourseResolver()

    return CoursesWidgetEntry(
      date: now,
      isLoggedIn: AppSettings.isWidgetLoggedIn(courseCache: cache),
      upcomingCourses: resolver.upcomingCourses(from: scheduledCourses, now: now),
      todayCount: scheduledCourses.filter { $0.weekday == weekday(for: now) }.count,
      showEnglishCourseName: loadPreference(
        key: AppSettings.showEnglishCourseNameKey,
        defaultValue: AppSettings.defaultShowEnglishName()
      ),
      showEnglishTeacherName: loadPreference(
        key: AppSettings.showEnglishTeacherNameKey,
        defaultValue: AppSettings.defaultShowEnglishName()
      )
    )
  }

  private func loadPreference(key: String, defaultValue: Bool) -> Bool {
    if AppSettings.appGroupDefaults.object(forKey: key) == nil {
      return defaultValue
    }

    return AppSettings.appGroupDefaults.bool(forKey: key)
  }

  private func loadCourseCache() -> CourseCache? {
    do {
      return try CourseCacheStore.live.load()
    } catch {
      return nil
    }
  }

  private func weekday(for date: Date) -> Int {
    let systemWeekday = Calendar.current.component(.weekday, from: date)
    return systemWeekday == 1 ? 7 : systemWeekday - 1
  }
}

struct CoursesNextUpWidget: Widget {
  let kind = "CoursesWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: CoursesWidgetProvider()) { entry in
      CoursesWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Upcoming Courses")
    .description("See your next classes and today's course count.")
    .supportedFamilies([.systemSmall, .accessoryRectangular])
  }
}

private struct CoursesWidgetEntryView: View {
  @Environment(\.widgetFamily) private var family
  let entry: CoursesWidgetEntry

  var body: some View {
    switch family {
    case .accessoryRectangular:
      CoursesNextUpLockScreenView(entry: entry)
    default:
      CoursesNextUpHomeWidgetView(entry: entry)
    }
  }
}

private let previewUpcomingCourses: [UpcomingScheduledCourse] = {
  let scheduledCourses = [
    ScheduledCourse(
      id: "preview-1",
      name: "模糊理論",
      enName: "FUZZY THEORY",
      teacher: "翁慶昌",
      teacherEn: "WONG CHING-CHANG",
      room: "E 414",
      seatNo: "009",
      note: "",
      weekday: 1,
      sessionNumbers: [6, 7],
      startTime: ScheduledCourse.time(from: "13:10") ?? Date(),
      endTime: ScheduledCourse.endTime(forSession: 7) ?? Date()
    ),
    ScheduledCourse(
      id: "preview-2",
      name: "資料結構",
      enName: "DATA STRUCTURES",
      teacher: "林教授",
      teacherEn: "PROF. LIN",
      room: "B 713",
      seatNo: "016",
      note: "",
      weekday: 2,
      sessionNumbers: [3, 4],
      startTime: ScheduledCourse.time(from: "10:10") ?? Date(),
      endTime: ScheduledCourse.endTime(forSession: 4) ?? Date()
    ),
  ]

  return UpcomingScheduledCourseResolver().upcomingCourses(from: scheduledCourses, now: Date())
}()
