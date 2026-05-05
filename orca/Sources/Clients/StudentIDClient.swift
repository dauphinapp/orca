import ComposableArchitecture
import Foundation

struct StudentIDClient {
  var fetchStudentID: @Sendable (_ sessionCookie: String) async throws -> String
}

enum StudentIDClientError: LocalizedError {
  case unavailable

  var errorDescription: String? {
    switch self {
    case .unavailable:
      "Student ID API is not available in this build."
    }
  }
}

extension StudentIDClient: DependencyKey {
  static let liveValue = Self(
    fetchStudentID: { _ in
      #if DEBUG
        return "123456789"
      #else
        throw StudentIDClientError.unavailable
      #endif
    }
  )

  static let testValue = Self(
    fetchStudentID: { _ in "123456789" }
  )
}

extension DependencyValues {
  var studentIDClient: StudentIDClient {
    get { self[StudentIDClient.self] }
    set { self[StudentIDClient.self] = newValue }
  }
}
