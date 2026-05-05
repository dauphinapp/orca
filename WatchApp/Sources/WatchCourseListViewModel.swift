import Foundation

@MainActor
final class WatchCourseListViewModel: ObservableObject {
  @Published private(set) var rows: [WatchCourseRow] = []
  @Published private(set) var hasLoadedCache = false
  @Published private(set) var errorMessage: String?

  private let store = CourseCacheStore.live
  private let decoder = JSONDecoder.courseCache
  private let calendar = Calendar.autoupdatingCurrent
  private lazy var sessionController = WatchCourseSessionController(delegate: self)
  private var showEnglishCourseName = AppSettings.defaultShowEnglishName()
  private var showEnglishTeacherName = AppSettings.defaultShowEnglishName()
  private var didStart = false

  func start() {
    guard !didStart else {
      return
    }

    didStart = true
    loadCachedCourses()
    sessionController.start()
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

extension WatchCourseListViewModel: WatchCourseSessionControllerDelegate {
  func watchCourseSessionControllerDidActivate() {
    sessionController.requestLatestCoursesIfPossible()
  }

  func watchCourseSessionControllerDidReceive(payloadData: Data?, cacheData: Data?) {
    apply(payloadData: payloadData, cacheData: cacheData)
  }
}
