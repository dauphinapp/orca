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

enum CoursesWidgetPreviewData {
  private static let calendar = Calendar.current
  private static let referenceDate = calendar.date(
    from: DateComponents(year: 2026, month: 4, day: 27, hour: 9, minute: 0)
  ) ?? Date()

  static let notLoggedIn = makeEntry(
    isLoggedIn: false,
    upcomingCourses: []
  )

  static let noUpcomingCourses = makeEntry(
    upcomingCourses: []
  )

  static let sameDayCourses = makeEntry(
    upcomingCourses: [
      makeUpcomingCourse(
        id: "preview-same-1",
        name: "模糊理論",
        enName: "FUZZY THEORY",
        teacher: "翁慶昌",
        teacherEn: "WONG CHING-CHANG",
        room: "E 414",
        seatNo: "009",
        dayOffset: 0,
        startHour: 13,
        startMinute: 10,
        endHour: 15,
        endMinute: 0
      ),
      makeUpcomingCourse(
        id: "preview-same-2",
        name: "資料結構",
        enName: "DATA STRUCTURES",
        teacher: "林教授",
        teacherEn: "PROF. LIN",
        room: "B 713",
        seatNo: "",
        dayOffset: 0,
        startHour: 15,
        startMinute: 10,
        endHour: 17,
        endMinute: 0
      ),
      makeUpcomingCourse(
        id: "preview-same-3",
        name: "演算法",
        enName: "ALGORITHMS",
        teacher: "王教授",
        teacherEn: "PROF. WANG",
        room: "A 201",
        seatNo: "021",
        dayOffset: 0,
        startHour: 18,
        startMinute: 10,
        endHour: 20,
        endMinute: 0
      ),
    ],
    todayCount: 3
  )

  static let mixedDayCourses = makeEntry(
    upcomingCourses: [
      makeUpcomingCourse(
        id: "preview-next-1",
        name: "線性代數",
        enName: "LINEAR ALGEBRA",
        teacher: "陳教授",
        teacherEn: "PROF. CHEN",
        room: "D 102",
        seatNo: "018",
        dayOffset: 1,
        startHour: 8,
        startMinute: 10,
        endHour: 10,
        endMinute: 0
      ),
      makeUpcomingCourse(
        id: "preview-next-2",
        name: "作業系統",
        enName: "OPERATING SYSTEMS",
        teacher: "李教授",
        teacherEn: "PROF. LEE",
        room: "E 208",
        seatNo: "035",
        dayOffset: 2,
        startHour: 10,
        startMinute: 10,
        endHour: 12,
        endMinute: 0
      ),
      makeUpcomingCourse(
        id: "preview-next-3",
        name: "機率",
        enName: "PROBABILITY",
        teacher: "張教授",
        teacherEn: "PROF. CHANG",
        room: "C 303",
        seatNo: "",
        dayOffset: 3,
        startHour: 13,
        startMinute: 10,
        endHour: 15,
        endMinute: 0
      ),
      makeUpcomingCourse(
        id: "preview-next-4",
        name: "電腦網路",
        enName: "COMPUTER NETWORKS",
        teacher: "吳教授",
        teacherEn: "PROF. WU",
        room: "F 101",
        seatNo: "012",
        dayOffset: 4,
        startHour: 15,
        startMinute: 10,
        endHour: 17,
        endMinute: 0
      ),
      makeUpcomingCourse(
        id: "preview-next-5",
        name: "編譯器",
        enName: "COMPILERS",
        teacher: "周教授",
        teacherEn: "PROF. CHOU",
        room: "A 501",
        seatNo: "027",
        dayOffset: 5,
        startHour: 18,
        startMinute: 10,
        endHour: 20,
        endMinute: 0
      ),
    ],
    todayCount: 5
  )

  static let englishNames = makeEntry(
    upcomingCourses: [
      makeUpcomingCourse(
        id: "preview-en-1",
        name: "計算機圖學",
        enName: "COMPUTER GRAPHICS",
        teacher: "黃教授",
        teacherEn: "PROF. HUANG",
        room: "G 301",
        seatNo: "031",
        dayOffset: 0,
        startHour: 9,
        startMinute: 10,
        endHour: 11,
        endMinute: 0
      ),
    ],
    todayCount: 1,
    showEnglishCourseName: true,
    showEnglishTeacherName: true
  )

  private static func makeEntry(
    isLoggedIn: Bool = true,
    upcomingCourses: [UpcomingScheduledCourse],
    todayCount: Int = 2,
    showEnglishCourseName: Bool = false,
    showEnglishTeacherName: Bool = false
  ) -> CoursesWidgetEntry {
    CoursesWidgetEntry(
      date: referenceDate,
      isLoggedIn: isLoggedIn,
      upcomingCourses: upcomingCourses,
      todayCount: todayCount,
      showEnglishCourseName: showEnglishCourseName,
      showEnglishTeacherName: showEnglishTeacherName
    )
  }

  private static func makeUpcomingCourse(
    id: String,
    name: String,
    enName: String,
    teacher: String,
    teacherEn: String,
    room: String,
    seatNo: String,
    dayOffset: Int,
    startHour: Int,
    startMinute: Int,
    endHour: Int,
    endMinute: Int
  ) -> UpcomingScheduledCourse {
    let courseDate = calendar.date(byAdding: .day, value: dayOffset, to: referenceDate) ?? referenceDate
    let startDate = calendar.date(
      bySettingHour: startHour,
      minute: startMinute,
      second: 0,
      of: courseDate
    ) ?? courseDate
    let endDate = calendar.date(
      bySettingHour: endHour,
      minute: endMinute,
      second: 0,
      of: courseDate
    ) ?? startDate.addingTimeInterval(50 * 60)

    let weekday = weekdayNumber(for: courseDate)
    let startTime = ScheduledCourse.time(from: String(format: "%02d:%02d", startHour, startMinute)) ?? startDate
    let endTime = ScheduledCourse.time(from: String(format: "%02d:%02d", endHour, endMinute)) ?? endDate

    let course = ScheduledCourse(
      id: id,
      name: name,
      enName: enName,
      teacher: teacher,
      teacherEn: teacherEn,
      room: room,
      seatNo: seatNo,
      note: "",
      weekday: weekday,
      sessionNumbers: [],
      startTime: startTime,
      endTime: endTime
    )

    return UpcomingScheduledCourse(course: course, startDate: startDate, endDate: endDate)
  }

  private static func weekdayNumber(for date: Date) -> Int {
    let systemWeekday = calendar.component(.weekday, from: date)
    return systemWeekday == 1 ? 7 : systemWeekday - 1
  }
}
