import Foundation
import Testing

@testable import orca

struct CalendarAndWidgetTests {
  @Test
  func calendarEventXMLParserParsesSingleAndRangedDates() throws {
    let xml = """
    <root>
      <cal>
        <週次>1</週次>
        <日期>2026-04-01</日期>
        <星期>三</星期>
        <事項>期中考公告</事項>
      </cal>
      <cal>
        <週次>2</週次>
        <日期>2026-04-10 ~ 2026-04-12</日期>
        <星期>五</星期>
        <事項>校慶</事項>
      </cal>
    </root>
    """

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let events = try CalendarEventXMLParser(calendar: calendar).parse(data: Data(xml.utf8))

    #expect(events.count == 2)
    #expect(events[0].event == "期中考公告")
    #expect(events[1].event == "校慶")
    #expect(events[1].startDate < events[1].endDate)
  }

  @Test
  func calendarEventXMLParserNormalizesReversedDateRanges() throws {
    let xml = """
    <root>
      <cal>
        <週次>7</週次>
        <日期>2026-05-12 ~ 2026-05-10</日期>
        <星期>二</星期>
        <事項>補課</事項>
      </cal>
    </root>
    """

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let event = try #require(
      CalendarEventXMLParser(calendar: calendar).parse(data: Data(xml.utf8)).first
    )

    #expect(event.startDate < event.endDate)
    #expect(calendar.component(.day, from: event.startDate) == 10)
    #expect(calendar.component(.day, from: event.endDate) == 12)
  }

  @Test
  func upcomingScheduledCourseResolverSkipsClassesEndingSoon() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let now = DateComponents(
      calendar: calendar,
      timeZone: calendar.timeZone,
      year: 2026,
      month: 4,
      day: 20,
      hour: 14,
      minute: 50
    ).date!

    let endingSoon = ScheduledCourse(
      id: "ending-soon",
      name: "A",
      enName: "A",
      teacher: "Teacher A",
      teacherEn: "Teacher A",
      room: "E 414",
      seatNo: "001",
      note: "",
      weekday: 1,
      sessionNumbers: [7],
      startTime: ScheduledCourse.time(from: "14:10", calendar: calendar) ?? now,
      endTime: ScheduledCourse.endTime(forSession: 7, calendar: calendar) ?? now
    )
    let laterToday = ScheduledCourse(
      id: "later-today",
      name: "B",
      enName: "B",
      teacher: "Teacher B",
      teacherEn: "Teacher B",
      room: "B 713",
      seatNo: "002",
      note: "",
      weekday: 1,
      sessionNumbers: [9],
      startTime: ScheduledCourse.time(from: "16:10", calendar: calendar) ?? now,
      endTime: ScheduledCourse.endTime(forSession: 9, calendar: calendar) ?? now
    )

    let upcoming = UpcomingScheduledCourseResolver(calendar: calendar).upcomingCourses(
      from: [endingSoon, laterToday],
      now: now
    )

    #expect(upcoming.first?.course.id == "later-today")
  }

  @Test
  func widgetLoginRequiresNonEmptyCourseCache() {
    #expect(AppSettings.isWidgetLoggedIn(courseCache: nil) == false)

    let emptyCache = CourseCache(updatedAt: Date(), courses: [])
    #expect(AppSettings.isWidgetLoggedIn(courseCache: emptyCache) == false)

    let populatedCache = CourseCache(updatedAt: Date(), courses: [widgetSampleCourse])
    #expect(AppSettings.isWidgetLoggedIn(courseCache: populatedCache) == true)
  }

  @Test
  func courseCacheStoreRoundTripsCacheThroughFallbackURL() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    let store = CourseCacheStore(
      appGroupIdentifier: "group.test.invalid",
      fallbackDirectory: directory
    )
    let cache = CourseCache(updatedAt: Date(), courses: [widgetSampleCourse])

    try store.save(cache)
    let loadedOptionalCache = try store.load()
    let loadedCache = try #require(loadedOptionalCache)
    let cacheURL = try store.cacheURL()

    #expect(loadedCache.courses == cache.courses)
    #expect(FileManager.default.fileExists(atPath: cacheURL.path))
  }

  @Test
  func courseCacheStoreReturnsNilWhenCacheFileIsMissing() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    let store = CourseCacheStore(
      appGroupIdentifier: "group.test.invalid",
      fallbackDirectory: directory
    )

    let loadedCache = try store.load()
    #expect(loadedCache == nil)
  }
}

private let widgetSampleCourse = CourseSession(
  weekno: "1",
  sessno: "06",
  week: "一",
  sesstime: "13:10",
  seatno: "009",
  chCosName: "模糊理論",
  enCosName: "FUZZY THEORY",
  teachName: "翁慶昌",
  teachNameEn: "WONG CHING-CHANG",
  note: "",
  room: "E  414"
)
