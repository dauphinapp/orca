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
  func upcomingScheduledCourseResolverSwitchesAtTMinus15Boundary() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let beforeCutover = DateComponents(
      calendar: calendar,
      timeZone: calendar.timeZone,
      year: 2026,
      month: 4,
      day: 20,
      hour: 10,
      minute: 44
    ).date!
    let atCutover = DateComponents(
      calendar: calendar,
      timeZone: calendar.timeZone,
      year: 2026,
      month: 4,
      day: 20,
      hour: 10,
      minute: 45
    ).date!
    let afterCutover = DateComponents(
      calendar: calendar,
      timeZone: calendar.timeZone,
      year: 2026,
      month: 4,
      day: 20,
      hour: 10,
      minute: 46
    ).date!

    let currentCourse = ScheduledCourse(
      id: "current-course",
      name: "Current",
      enName: "Current",
      teacher: "Teacher C",
      teacherEn: "Teacher C",
      room: "E 414",
      seatNo: "001",
      note: "",
      weekday: 1,
      sessionNumbers: [5],
      startTime: ScheduledCourse.time(from: "10:00", calendar: calendar) ?? beforeCutover,
      endTime: ScheduledCourse.time(from: "10:50", calendar: calendar) ?? beforeCutover
    )
    let nextCourse = ScheduledCourse(
      id: "next-course",
      name: "Next",
      enName: "Next",
      teacher: "Teacher N",
      teacherEn: "Teacher N",
      room: "B 713",
      seatNo: "002",
      note: "",
      weekday: 1,
      sessionNumbers: [6],
      startTime: ScheduledCourse.time(from: "11:00", calendar: calendar) ?? beforeCutover,
      endTime: ScheduledCourse.time(from: "11:50", calendar: calendar) ?? beforeCutover
    )

    let resolver = UpcomingScheduledCourseResolver(calendar: calendar)

    let before = resolver.upcomingCourses(
      from: [currentCourse, nextCourse],
      now: beforeCutover
    )
    let at = resolver.upcomingCourses(
      from: [currentCourse, nextCourse],
      now: atCutover
    )
    let after = resolver.upcomingCourses(
      from: [currentCourse, nextCourse],
      now: afterCutover
    )

    #expect(before.first?.course.id == "current-course")
    #expect(at.first?.course.id == "next-course")
    #expect(after.first?.course.id == "next-course")
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

  @Test
  func watchCoursePayloadRoundTripsThroughCourseCacheCoding() throws {
    let payload = WatchCoursePayload(
      cache: CourseCache(updatedAt: Date(), courses: [widgetSampleCourse]),
      showEnglishCourseName: true,
      showEnglishTeacherName: false
    )

    let data = try JSONEncoder.courseCache.encode(payload)
    let decodedPayload = try JSONDecoder.courseCache.decode(WatchCoursePayload.self, from: data)

    #expect(decodedPayload == payload)
  }

  @Test
  func scheduledCoursesSortForWatchWeekList() {
    let tuesdayEarly = CourseSession(
      weekno: "2",
      sessno: "03",
      week: "二",
      sesstime: "10:10",
      seatno: "016",
      chCosName: "資料結構",
      enCosName: "DATA STRUCTURES",
      teachName: "林教授",
      teachNameEn: "PROF. LIN",
      note: "",
      room: "B 713"
    )
    let mondayLate = CourseSession(
      weekno: "1",
      sessno: "08",
      week: "一",
      sesstime: "15:10",
      seatno: "009",
      chCosName: "模糊理論",
      enCosName: "FUZZY THEORY",
      teachName: "翁慶昌",
      teachNameEn: "WONG CHING-CHANG",
      note: "",
      room: "E 414"
    )
    let mondayEarly = CourseSession(
      weekno: "1",
      sessno: "06",
      week: "一",
      sesstime: "13:10",
      seatno: "010",
      chCosName: "線性代數",
      enCosName: "LINEAR ALGEBRA",
      teachName: "陳教授",
      teachNameEn: "PROF. CHEN",
      note: "",
      room: "S 101"
    )

    let courses = [tuesdayEarly, mondayLate, mondayEarly].scheduledCourses()

    #expect(courses.map(\.name) == ["線性代數", "模糊理論", "資料結構"])
    #expect(courses.map(\.weekday) == [1, 1, 2])
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
