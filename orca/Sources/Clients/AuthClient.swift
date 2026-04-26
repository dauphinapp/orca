import ComposableArchitecture
import Foundation
import WebKit

struct AuthClient {
  var loadSessionCookie: @Sendable () async -> String?
  var saveSessionCookie: @Sendable (String) async throws -> Void
  var clearSessionCookie: @Sendable () async throws -> Void
}

extension AuthClient: DependencyKey {
  static let liveValue = Self(
    loadSessionCookie: {
      KeychainClient.live.loadString(.sessionCookie)
    },
    saveSessionCookie: { cookie in
      try KeychainClient.live.saveString(cookie, .sessionCookie)
    },
    clearSessionCookie: {
      var keychainError: Error?
      do {
        try KeychainClient.live.delete(.sessionCookie)
      } catch {
        keychainError = error
      }

      await clearWebSession()

      if let keychainError {
        throw keychainError
      }
    }
  )

  static let testValue = Self(
    loadSessionCookie: { nil },
    saveSessionCookie: { _ in },
    clearSessionCookie: {}
  )
}

@MainActor
private func clearWebSession() async {
  let dataStore = WKWebsiteDataStore.default()
  let cookies = await withCheckedContinuation { continuation in
    dataStore.httpCookieStore.getAllCookies { cookies in
      continuation.resume(returning: cookies)
    }
  }

  for cookie in cookies {
    await withCheckedContinuation { continuation in
      dataStore.httpCookieStore.delete(cookie) {
        continuation.resume()
      }
    }
  }

  await withCheckedContinuation { continuation in
    dataStore.removeData(
      ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
      modifiedSince: .distantPast
    ) {
      continuation.resume()
    }
  }
}

extension DependencyValues {
  var authClient: AuthClient {
    get { self[AuthClient.self] }
    set { self[AuthClient.self] = newValue }
  }
}
