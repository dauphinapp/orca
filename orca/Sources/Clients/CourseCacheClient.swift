import ComposableArchitecture
import Foundation

struct CourseCacheClient {
  var load: @Sendable () async throws -> CourseCache?
  var save: @Sendable (CourseCache) async throws -> Void
  var clear: @Sendable () async throws -> Void
}

extension CourseCacheClient: DependencyKey {
  static let liveValue = Self(
    load: {
      try CourseCacheStore.live.load()
    },
    save: { cache in
      try CourseCacheStore.live.save(cache)
    },
    clear: {
      try CourseCacheStore.live.clear()
    }
  )

  static let testValue = Self(
    load: { nil },
    save: { _ in },
    clear: {}
  )
}

extension DependencyValues {
  var courseCacheClient: CourseCacheClient {
    get { self[CourseCacheClient.self] }
    set { self[CourseCacheClient.self] = newValue }
  }
}
