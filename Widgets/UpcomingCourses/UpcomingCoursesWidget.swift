import Foundation
import SwiftUI
import WidgetKit

struct UpcomingCoursesWidgetEntry: TimelineEntry {
  let date: Date
  let isLoggedIn: Bool
  let upcomingCourses: [UpcomingScheduledCourse]
  let todayCount: Int
  let showEnglishCourseName: Bool
  let showEnglishTeacherName: Bool
}

struct UpcomingCoursesWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> UpcomingCoursesWidgetEntry {
    UpcomingCoursesWidgetEntry(
      date: Date(),
      isLoggedIn: true,
      upcomingCourses: previewUpcomingCourses,
      todayCount: 2,
      showEnglishCourseName: false,
      showEnglishTeacherName: false
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (UpcomingCoursesWidgetEntry) -> Void) {
    completion(makeEntry(now: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<UpcomingCoursesWidgetEntry>) -> Void) {
    let now = Date()
    let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: now) ?? now.addingTimeInterval(900)
    let entry = makeEntry(now: now)
    completion(Timeline(entries: [entry], policy: .after(refreshDate)))
  }

  private func makeEntry(now: Date) -> UpcomingCoursesWidgetEntry {
    let cache = loadCourseCache()
    let scheduledCourses = cache?.courses.scheduledCourses() ?? []
    let resolver = UpcomingScheduledCourseResolver()

    return UpcomingCoursesWidgetEntry(
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

struct UpcomingCoursesWidget: Widget {
  let kind = "Widgets"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: UpcomingCoursesWidgetProvider()) { entry in
      UpcomingCoursesWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Upcoming Courses")
    .description("See your next classes and today's course count.")
    .supportedFamilies([.systemSmall, .accessoryRectangular])
  }
}

private struct UpcomingCoursesWidgetEntryView: View {
  @Environment(\.widgetFamily) private var family
  let entry: UpcomingCoursesWidgetEntry

  var body: some View {
    switch family {
    case .accessoryRectangular:
      UpcomingCoursesLockScreenWidgetView(entry: entry)
    default:
      UpcomingCoursesHomeWidgetView(entry: entry)
    }
  }
}

#Preview("Entry View / Small") {
  UpcomingCoursesWidgetEntryView(entry: UpcomingCoursesWidgetPreviewData.sameDayCourses)
}

#Preview("Entry View / Lock Screen") {
  UpcomingCoursesWidgetEntryView(entry: UpcomingCoursesWidgetPreviewData.sameDayCourses)
}
