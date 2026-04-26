import ComposableArchitecture
import Foundation
import WidgetKit

struct WidgetTimelineClient {
  var reloadCoursesWidget: @Sendable () async -> Void
}

extension WidgetTimelineClient: DependencyKey {
  static let liveValue = Self(
    reloadCoursesWidget: {
      WidgetCenter.shared.reloadTimelines(ofKind: "CoursesWidget")
    }
  )

  static let testValue = Self(
    reloadCoursesWidget: {}
  )
}

extension DependencyValues {
  var widgetTimelineClient: WidgetTimelineClient {
    get { self[WidgetTimelineClient.self] }
    set { self[WidgetTimelineClient.self] = newValue }
  }
}
