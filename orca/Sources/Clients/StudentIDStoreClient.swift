import ComposableArchitecture
import Foundation

struct StudentIDStoreClient {
  var load: @Sendable () async throws -> StudentIDRecord?
  var save: @Sendable (StudentIDRecord) async throws -> Void
  var clear: @Sendable () async throws -> Void
}

extension StudentIDStoreClient: DependencyKey {
  static let liveValue = Self(
    load: {
      try StudentIDStore.live.load()
    },
    save: { record in
      try StudentIDStore.live.save(record)
    },
    clear: {
      try StudentIDStore.live.clear()
    }
  )

  static let testValue = Self(
    load: { nil },
    save: { _ in },
    clear: {}
  )
}

extension DependencyValues {
  var studentIDStoreClient: StudentIDStoreClient {
    get { self[StudentIDStoreClient.self] }
    set { self[StudentIDStoreClient.self] = newValue }
  }
}
