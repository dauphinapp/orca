import Foundation

enum AppSettings {
  static let appGroupSuiteName = "group.cantpr09ram.dauphin"
  static let widgetIsLoggedInKey = "widgetIsLoggedIn"
  static let showEnglishCourseNameKey = "showEnglishCourseName"
  static let showEnglishTeacherNameKey = "showEnglishTeacherName"
  static let showWeekendDaysKey = "showWeekendDays"
  static let eventCalendarEndpoint = "https://ilifeapi.az.tku.edu.tw/data/xml_cal.ashx"

  static var appGroupDefaults: UserDefaults {
    UserDefaults(suiteName: appGroupSuiteName) ?? .standard
  }

  static func isWidgetLoggedIn(courseCache: CourseCache?) -> Bool {
    guard let courseCache else {
      return false
    }

    return !courseCache.courses.isEmpty
  }

  static func hasActiveWidgetSession() -> Bool {
    appGroupDefaults.bool(forKey: widgetIsLoggedInKey)
  }

  static func defaultShowEnglishName(
    preferredLanguage: String? = Locale.preferredLanguages.first
  ) -> Bool {
    guard let preferredLanguage else {
      return true
    }

    let normalized = preferredLanguage
      .lowercased()
      .replacingOccurrences(of: "_", with: "-")

    let isTraditionalChinese =
      normalized.hasPrefix("zh-hant")
      || normalized.hasPrefix("zh-tw")
      || normalized.hasPrefix("zh-hk")
      || normalized.hasPrefix("zh-mo")

    return !isTraditionalChinese
  }

  static func defaultShowWeekendDays() -> Bool {
    false
  }
}
