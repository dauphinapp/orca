import ComposableArchitecture
import Foundation
import WidgetKit

struct WidgetTimelineClient {
  var reloadCoursesWidget: @Sendable () async -> Void
  var reloadStudentIDWidget: @Sendable () async -> Void
}

extension WidgetTimelineClient: DependencyKey {
  static let liveValue = Self(
    reloadCoursesWidget: {
      WidgetCenter.shared.reloadTimelines(ofKind: "CoursesWidget")
    },
    reloadStudentIDWidget: {
      WidgetCenter.shared.reloadTimelines(ofKind: "StudentIDWidget")
    }
  )

  static let testValue = Self(
    reloadCoursesWidget: {},
    reloadStudentIDWidget: {}
  )
}

extension DependencyValues {
  var widgetTimelineClient: WidgetTimelineClient {
    get { self[WidgetTimelineClient.self] }
    set { self[WidgetTimelineClient.self] = newValue }
  }
}
