import Foundation
import WatchConnectivity

@MainActor
protocol WatchCourseSessionControllerDelegate: AnyObject {
  func watchCourseSessionControllerDidActivate()
  func watchCourseSessionControllerDidReceive(payloadData: Data?, cacheData: Data?)
}

@MainActor
final class WatchCourseSessionController: NSObject {
  weak var delegate: WatchCourseSessionControllerDelegate?

  init(delegate: WatchCourseSessionControllerDelegate) {
    self.delegate = delegate
  }

  func start() {
    guard WCSession.isSupported() else {
      return
    }

    let session = WCSession.default
    session.delegate = self
    session.activate()
    delegate?.watchCourseSessionControllerDidReceive(
      payloadData: session.receivedApplicationContext["coursePayload"] as? Data,
      cacheData: session.receivedApplicationContext["courseCache"] as? Data
    )
    requestLatestCoursesIfPossible(session)
  }

  func requestLatestCoursesIfPossible(_ session: WCSession = .default) {
    guard session.activationState == .activated, session.isReachable else {
      return
    }

    session.sendMessage(["requestCourseCache": true], replyHandler: nil)
  }
}

extension WatchCourseSessionController: WCSessionDelegate {
  nonisolated func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    guard activationState == .activated else {
      return
    }

    Task { @MainActor [weak self] in
      self?.delegate?.watchCourseSessionControllerDidActivate()
    }
  }

  nonisolated func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String: Any]
  ) {
    let payloadData = applicationContext["coursePayload"] as? Data
    let cacheData = applicationContext["courseCache"] as? Data

    Task { @MainActor [weak self] in
      self?.delegate?.watchCourseSessionControllerDidReceive(
        payloadData: payloadData,
        cacheData: cacheData
      )
    }
  }
}
