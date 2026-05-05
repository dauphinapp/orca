import ComposableArchitecture
import Foundation
import WidgetKit

struct WidgetTimelineClient {
  var reloadWidgets: @Sendable () async -> Void
  var reloadStudentIDWidget: @Sendable () async -> Void
}

extension WidgetTimelineClient: DependencyKey {
  static let liveValue = Self(
    reloadWidgets: {
      WidgetCenter.shared.reloadTimelines(ofKind: "Widgets")
    },
    reloadStudentIDWidget: {
      WidgetCenter.shared.reloadTimelines(ofKind: "StudentIDWidget")
    }
  )

  static let testValue = Self(
    reloadWidgets: {},
    reloadStudentIDWidget: {}
  )
}

extension DependencyValues {
  var widgetTimelineClient: WidgetTimelineClient {
    get { self[WidgetTimelineClient.self] }
    set { self[WidgetTimelineClient.self] = newValue }
  }
}
