import ComposableArchitecture
import Foundation
import Testing

@testable import orca

@MainActor
struct AppFeatureTests {
  @Test
  func taskWithSessionCookieShowsContent() async {
    let store = TestStore(initialState: AppFeature.State(isLoadingSession: false)) {
      AppFeature()
    } withDependencies: {
      $0.authClient.loadSessionCookie = { "session-value" }
    }

    await store.send(.task) {
      $0.hasStartedSessionLoad = true
      $0.isLoadingSession = true
    }
    await store.receive(.sessionLoadFinished(sessionCookie: "session-value")) {
      $0.isLoadingSession = false
      $0.destination = .content
      $0.sessionCookie = "session-value"
    }
  }

  @Test
  func taskWithoutSessionAndWithoutOnboardingShowsOnboarding() async {
    let store = TestStore(initialState: AppFeature.State(isLoadingSession: false)) {
      AppFeature()
    } withDependencies: {
      $0.authClient.loadSessionCookie = { nil }
    }

    await store.send(.task) {
      $0.hasStartedSessionLoad = true
      $0.isLoadingSession = true
    }
    await store.receive(.sessionLoadFinished(sessionCookie: nil)) {
      $0.isLoadingSession = false
      $0.destination = .onboarding
      $0.sessionCookie = nil
    }
  }

  @Test
  func taskWithoutSessionAfterOnboardingStillShowsOnboarding() async {
    let store = TestStore(initialState: AppFeature.State(isLoadingSession: false)) {
      AppFeature()
    } withDependencies: {
      $0.authClient.loadSessionCookie = { nil }
    }

    await store.send(.task) {
      $0.hasStartedSessionLoad = true
      $0.isLoadingSession = true
    }
    await store.receive(.sessionLoadFinished(sessionCookie: nil)) {
      $0.isLoadingSession = false
      $0.destination = .onboarding
      $0.sessionCookie = nil
    }
  }

  @Test
  func getStartedShowsLogin() async {
    let store = TestStore(initialState: AppFeature.State(isLoadingSession: false)) {
      AppFeature()
    }

    await store.send(.getStartedTapped) {
      $0.destination = .login
    }
  }

  @Test
  func loginCookieReceivedSavesSessionAndShowsContent() async {
    let savedCookie = StringBox()

    let store = TestStore(
      initialState: AppFeature.State(destination: .login, isLoadingSession: false)
    ) {
      AppFeature()
    } withDependencies: {
      $0.authClient.saveSessionCookie = { cookie in
        await savedCookie.set(cookie)
      }
    }

    await store.send(.loginCookieReceived("session-value"))
    await store.receive(.sessionSaved("session-value")) {
      $0.destination = .content
      $0.sessionCookie = "session-value"
    }

    #expect(await savedCookie.value == "session-value")
  }

  @Test
  func loginCookieSaveFailureStaysOnLogin() async {
    let store = TestStore(
      initialState: AppFeature.State(destination: .login, isLoadingSession: false)
    ) {
      AppFeature()
    } withDependencies: {
      $0.authClient.saveSessionCookie = { _ in
        throw TestError()
      }
    }

    await store.send(.loginCookieReceived("session-value"))
    await store.receive(.sessionSaveFailed("failed")) {
      $0.destination = .login
      $0.loginErrorMessage = "failed"
    }
  }

  @Test
  func repeatedTaskDoesNotReloadSession() async {
    let store = TestStore(
      initialState: AppFeature.State(
        destination: .onboarding,
        hasStartedSessionLoad: true,
        isLoadingSession: false
      )
    ) {
      AppFeature()
    } withDependencies: {
      $0.authClient.loadSessionCookie = { "session-value" }
    }

    await store.send(.task)
  }

  @Test
  func contentTaskFetchesCourses() async {
    let savedCache = CourseCacheBox()
    let syncedCache = CourseCacheBox()
    let didReloadWidget = BoolBox()
    let savedStudentID = StringBox()
    let didReloadStudentIDWidget = BoolBox()

    let store = TestStore(
      initialState: AppFeature.State(
        destination: .content,
        sessionCookie: "session-value",
        isLoadingSession: false
      )
    ) {
      AppFeature()
    } withDependencies: {
      $0.courseClient.fetchCourses = { cookie in
        #expect(cookie == "session-value")
        return [sampleCourse]
      }
      $0.courseCacheClient.save = { cache in
        await savedCache.set(cache)
      }
      $0.watchCourseSyncClient.sync = { cache in
        await syncedCache.set(cache)
      }
      $0.widgetTimelineClient.reloadWidgets = {
        await didReloadWidget.set(true)
      }
      $0.studentIDClient.fetchStudentID = { cookie in
        #expect(cookie == "session-value")
        return "123456789"
      }
      $0.studentIDStoreClient.save = { record in
        await savedStudentID.set(record.studentID)
      }
      $0.widgetTimelineClient.reloadStudentIDWidget = {
        await didReloadStudentIDWidget.set(true)
      }
    }

    await store.send(.contentTask) {
      $0.hasStartedCourseLoad = true
      $0.isLoadingCourses = true
    }
    await store.receive(.coursesLoaded([sampleCourse])) {
      $0.courses = [sampleCourse]
      $0.isLoadingCourses = false
    }

    #expect(await savedCache.value?.courses == [sampleCourse])
    #expect(await syncedCache.value?.courses == [sampleCourse])
    #expect(await didReloadWidget.value == true)
    #expect(await savedStudentID.value == "123456789")
    #expect(await didReloadStudentIDWidget.value == true)
  }

  @Test
  func contentTaskKeepsCoursesWhenCacheSaveFails() async {
    let syncedCache = CourseCacheBox()
    let didReloadWidget = BoolBox()
    let savedStudentID = StringBox()
    let store = TestStore(
      initialState: AppFeature.State(
        destination: .content,
        sessionCookie: "session-value",
        isLoadingSession: false
      )
    ) {
      AppFeature()
    } withDependencies: {
      $0.courseClient.fetchCourses = { _ in [sampleCourse] }
      $0.courseCacheClient.save = { _ in
        throw TestError()
      }
      $0.watchCourseSyncClient.sync = { cache in
        await syncedCache.set(cache)
      }
      $0.widgetTimelineClient.reloadWidgets = {
        await didReloadWidget.set(true)
      }
      $0.studentIDStoreClient.save = { record in
        await savedStudentID.set(record.studentID)
      }
    }

    await store.send(.contentTask) {
      $0.hasStartedCourseLoad = true
      $0.isLoadingCourses = true
    }
    await store.receive(.cacheSyncFailed("failed")) {
      $0.cacheWarningMessage = "failed"
    }
    await store.receive(.coursesLoaded([sampleCourse])) {
      $0.courses = [sampleCourse]
      $0.isLoadingCourses = false
    }

    #expect(await syncedCache.value?.courses == [sampleCourse])
    #expect(await didReloadWidget.value == false)
    #expect(await savedStudentID.value == "123456789")
  }

  @Test
  func contentTaskKeepsCoursesWhenStudentIDSyncFails() async {
    let savedCache = CourseCacheBox()
    let didReloadWidgets = BoolBox()
    let didReloadStudentIDWidget = BoolBox()

    let store = TestStore(
      initialState: AppFeature.State(
        destination: .content,
        sessionCookie: "session-value",
        isLoadingSession: false
      )
    ) {
      AppFeature()
    } withDependencies: {
      $0.courseClient.fetchCourses = { _ in [sampleCourse] }
      $0.courseCacheClient.save = { cache in
        await savedCache.set(cache)
      }
      $0.studentIDClient.fetchStudentID = { _ in
        throw TestError()
      }
      $0.widgetTimelineClient.reloadWidgets = {
        await didReloadWidgets.set(true)
      }
      $0.widgetTimelineClient.reloadStudentIDWidget = {
        await didReloadStudentIDWidget.set(true)
      }
    }

    await store.send(.contentTask) {
      $0.hasStartedCourseLoad = true
      $0.isLoadingCourses = true
    }
    await store.receive(.coursesLoaded([sampleCourse])) {
      $0.courses = [sampleCourse]
      $0.isLoadingCourses = false
    }

    #expect(await savedCache.value?.courses == [sampleCourse])
    #expect(await didReloadWidgets.value == true)
    #expect(await didReloadStudentIDWidget.value == false)
  }

  @Test
  func contentTaskFailureAllowsRetry() async {
    let store = TestStore(
      initialState: AppFeature.State(
        destination: .content,
        sessionCookie: "session-value",
        isLoadingSession: false
      )
    ) {
      AppFeature()
    } withDependencies: {
      $0.courseClient.fetchCourses = { _ in
        throw TestError()
      }
    }

    await store.send(.contentTask) {
      $0.hasStartedCourseLoad = true
      $0.isLoadingCourses = true
    }
    await store.receive(.coursesFailed("failed")) {
      $0.hasStartedCourseLoad = false
      $0.isLoadingCourses = false
      $0.courseErrorMessage = "failed"
    }
  }

  @Test
  func contentTaskUnauthorizedReturnsToOnboarding() async {
    let didClear = BoolBox()
    let didReloadWidget = BoolBox()
    let didClearStudentID = BoolBox()
    let didReloadStudentIDWidget = BoolBox()
    let store = TestStore(
      initialState: AppFeature.State(
        destination: .content,
        sessionCookie: "session-value",
        isLoadingSession: false
      )
    ) {
      AppFeature()
    } withDependencies: {
      $0.courseClient.fetchCourses = { _ in
        throw CourseClientError.unauthorized
      }
      $0.authClient.clearSessionCookie = {
        await didClear.set(true)
      }
      $0.studentIDStoreClient.clear = {
        await didClearStudentID.set(true)
      }
      $0.widgetTimelineClient.reloadWidgets = {
        await didReloadWidget.set(true)
      }
      $0.widgetTimelineClient.reloadStudentIDWidget = {
        await didReloadStudentIDWidget.set(true)
      }
    }

    await store.send(.contentTask) {
      $0.hasStartedCourseLoad = true
      $0.isLoadingCourses = true
    }
    await store.receive(.apiUnauthorized) {
      $0.destination = .onboarding
      $0.sessionCookie = nil
      $0.hasStartedCourseLoad = false
      $0.isLoadingCourses = false
      $0.courses = []
    }
    await store.receive(.sessionCleared)

    #expect(await didClear.value == true)
    #expect(await didReloadWidget.value == true)
    #expect(await didClearStudentID.value == true)
    #expect(await didReloadStudentIDWidget.value == true)
  }

  @Test
  func loginCookieReceivedOutsideLoginIsIgnored() async {
    let savedCookie = StringBox()
    let store = TestStore(
      initialState: AppFeature.State(destination: .onboarding, isLoadingSession: false)
    ) {
      AppFeature()
    } withDependencies: {
      $0.authClient.saveSessionCookie = { cookie in
        await savedCookie.set(cookie)
      }
    }

    await store.send(.loginCookieReceived("session-value"))

    #expect(await savedCookie.value == nil)
  }

  @Test
  func logoutClearsSessionAndShowsOnboarding() async {
    let didClear = BoolBox()
    let didClearCache = BoolBox()
    let didReloadWidget = BoolBox()
    let didClearStudentID = BoolBox()
    let didReloadStudentIDWidget = BoolBox()
    let store = TestStore(
      initialState: AppFeature.State(destination: .content, isLoadingSession: false)
    ) {
      AppFeature()
    } withDependencies: {
      $0.authClient.clearSessionCookie = {
        await didClear.set(true)
      }
      $0.courseCacheClient.clear = {
        await didClearCache.set(true)
      }
      $0.studentIDStoreClient.clear = {
        await didClearStudentID.set(true)
      }
      $0.widgetTimelineClient.reloadWidgets = {
        await didReloadWidget.set(true)
      }
      $0.widgetTimelineClient.reloadStudentIDWidget = {
        await didReloadStudentIDWidget.set(true)
      }
    }

    await store.send(.logoutRequested) {
      $0.destination = .onboarding
    }
    await store.receive(.sessionCleared)

    #expect(await didClear.value == true)
    #expect(await didClearCache.value == true)
    #expect(await didReloadWidget.value == true)
    #expect(await didClearStudentID.value == true)
    #expect(await didReloadStudentIDWidget.value == true)
  }

  @Test
  func nextCourseResolverFindsUpcomingCourse() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let now = DateComponents(
      calendar: calendar,
      timeZone: calendar.timeZone,
      year: 2026,
      month: 4,
      day: 20,
      hour: 14,
      minute: 30
    ).date!

    let nextCourse = NextCourseResolver(calendar: calendar).nextCourse(
      from: [
        sampleCourse,
        CourseSession(
          weekno: "1",
          sessno: "09",
          week: "一",
          sesstime: "16:10",
          seatno: "051",
          chCosName: "運動志工精神與服務",
          enCosName: "SPORTS VOLUNTEER AND SOCIAL SERVICE",
          teachName: "黃貴樹",
          teachNameEn: "HUANG, KUEI-SHU",
          note: "",
          room: "B  713"
        ),
      ],
      now: now
    )

    #expect(nextCourse?.course.chCosName == "運動志工精神與服務")
  }

  @Test
  func coursesGroupedForDisplayMergeConsecutiveSameCourseSessions() {
    let courses = [
      sampleCourse,
      CourseSession(
        weekno: "1",
        sessno: "07",
        week: "一",
        sesstime: "14:10",
        seatno: "009",
        chCosName: "模糊理論",
        enCosName: "FUZZY THEORY",
        teachName: "翁慶昌",
        teachNameEn: "WONG CHING-CHANG",
        note: "",
        room: "E  414"
      ),
      CourseSession(
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
        room: "E  414"
      ),
    ]

    let groupedCourses = courses.groupedForDisplay()

    #expect(groupedCourses.count == 1)
    #expect(groupedCourses[0].timeText == "06-08 13:10")
    #expect(groupedCourses[0].sessions == courses)
  }

  @Test
  func coursesGroupedForDisplayDoesNotMergeSeparatedOrDifferentCourseSessions() {
    let groupedCourses = [
      sampleCourse,
      CourseSession(
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
        room: "E  414"
      ),
      CourseSession(
        weekno: "1",
        sessno: "09",
        week: "一",
        sesstime: "16:10",
        seatno: "051",
        chCosName: "運動志工精神與服務",
        enCosName: "SPORTS VOLUNTEER AND SOCIAL SERVICE",
        teachName: "黃貴樹",
        teachNameEn: "HUANG, KUEI-SHU",
        note: "",
        room: "B  713"
      ),
    ].groupedForDisplay()

    #expect(groupedCourses.count == 3)
  }

  @Test
  func courseSessionsConvertToScheduledCourses() {
    let courses = [
      sampleCourse,
      CourseSession(
        weekno: "1",
        sessno: "07",
        week: "一",
        sesstime: "14:10",
        seatno: "009",
        chCosName: "模糊理論",
        enCosName: "FUZZY THEORY",
        teachName: "翁慶昌",
        teachNameEn: "WONG CHING-CHANG",
        note: "",
        room: "E  414"
      ),
    ].scheduledCourses()

    #expect(courses.count == 1)
    #expect(courses[0].weekday == 1)
    #expect(courses[0].sessionNumbers == [6, 7])
    #expect(courses[0].name == "模糊理論")
    #expect(courses[0].displayName(showEnglish: true) == "FUZZY THEORY")
    #expect(courses[0].displayTeacher(showEnglish: true) == "WONG CHING-CHANG")

    let calendar = Calendar.current
    #expect(calendar.component(.hour, from: courses[0].startTime) == 13)
    #expect(calendar.component(.minute, from: courses[0].startTime) == 10)
    #expect(calendar.component(.hour, from: courses[0].endTime) == 15)
    #expect(calendar.component(.minute, from: courses[0].endTime) == 0)
  }

  @Test
  func scheduledCourseFallsBackWhenEnglishFieldsAreEmpty() {
    let course = CourseSession(
      weekno: "2",
      sessno: "03",
      week: "二",
      sesstime: "10:10",
      seatno: "016",
      chCosName: "資料結構",
      enCosName: "",
      teachName: "林教授",
      teachNameEn: "",
      note: "",
      room: "B  713"
    ).scheduledCourseForTest()

    #expect(course?.displayName(showEnglish: true) == "資料結構")
    #expect(course?.displayTeacher(showEnglish: true) == "林教授")
  }

  @Test
  func appSettingsDefaultEnglishPreferenceFollowsLanguage() {
    #expect(AppSettings.defaultShowEnglishName(preferredLanguage: "zh-Hant-TW") == false)
    #expect(AppSettings.defaultShowEnglishName(preferredLanguage: "en-US") == true)
    #expect(AppSettings.defaultShowEnglishName(preferredLanguage: nil) == true)
  }

  @Test
  func campusCoordinateUsesRoomPrefix() {
    let coordinate = CampusLocations.coordinate(forRoom: "E  414")

    #expect(coordinate.latitude == 25.1761)
    #expect(coordinate.longitude == 121.452)
  }
}

private actor BoolBox {
  private var storedValue: Bool

  init(initialValue: Bool = false) {
    self.storedValue = initialValue
  }

  var value: Bool {
    storedValue
  }

  func set(_ value: Bool) {
    storedValue = value
  }
}

private actor StringBox {
  private var storedValue: String?

  var value: String? {
    storedValue
  }

  func set(_ value: String) {
    storedValue = value
  }
}

private actor CourseCacheBox {
  private var storedValue: CourseCache?

  var value: CourseCache? {
    storedValue
  }

  func set(_ value: CourseCache) {
    storedValue = value
  }
}

private struct TestError: LocalizedError {
  var errorDescription: String? {
    "failed"
  }
}

private let sampleCourse = CourseSession(
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

private extension CourseSession {
  func scheduledCourseForTest() -> ScheduledCourse? {
    [self].scheduledCourses().first
  }
}
