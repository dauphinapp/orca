import ComposableArchitecture
import Foundation

#if canImport(WatchConnectivity)
  import WatchConnectivity
#endif

struct WatchCourseSyncClient {
  var sync: @Sendable (CourseCache) async -> Void
}

extension WatchCourseSyncClient: DependencyKey {
  static let liveValue = Self(
    sync: { cache in
      #if canImport(WatchConnectivity)
        await MainActor.run {
          WatchCourseSyncService.shared.sync(cache)
        }
      #else
        _ = cache
      #endif
    }
  )

  static let testValue = Self(
    sync: { _ in }
  )
}

extension DependencyValues {
  var watchCourseSyncClient: WatchCourseSyncClient {
    get { self[WatchCourseSyncClient.self] }
    set { self[WatchCourseSyncClient.self] = newValue }
  }
}

#if canImport(WatchConnectivity)
  @MainActor
  private final class WatchCourseSyncService: NSObject, WCSessionDelegate {
    static let shared = WatchCourseSyncService()

    private let encoder = JSONEncoder()
    private var pendingCache: CourseCache?

    private override init() {
      encoder.dateEncodingStrategy = .iso8601
      super.init()
    }

    func sync(_ cache: CourseCache) {
      guard WCSession.isSupported() else {
        return
      }

      pendingCache = cache

      let session = WCSession.default
      if session.activationState == .notActivated {
        session.delegate = self
        session.activate()
        return
      }

      sendPendingCacheIfPossible(session)
    }

    private func sendPendingCacheIfPossible(_ session: WCSession = .default) {
      guard session.activationState == .activated else {
        return
      }

      guard let pendingCache, let data = try? encoder.encode(pendingCache) else {
        return
      }

      let payload = ["courseCache": data]
      if session.isPaired, session.isWatchAppInstalled {
        do {
          try session.updateApplicationContext(payload)
          self.pendingCache = nil
        } catch {}
      }
    }

    nonisolated func session(
      _ session: WCSession,
      activationDidCompleteWith activationState: WCSessionActivationState,
      error: Error?
    ) {
      guard activationState == .activated else {
        return
      }

      Task { @MainActor in
        self.sendPendingCacheIfPossible()
      }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
      session.activate()
    }
  }
#endif
