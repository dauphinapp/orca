import ComposableArchitecture
import Foundation

struct CourseClient {
  var fetchCourses: @Sendable (_ sessionCookie: String) async throws -> [CourseSession]
}

enum CourseClientError: LocalizedError {
  case invalidURL
  case unauthorized
  case invalidResponse

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      "Invalid course API URL."
    case .unauthorized:
      "Session expired. Please sign in again."
    case .invalidResponse:
      "Course API returned an invalid response."
    }
  }
}

extension CourseClient: DependencyKey {
  static let liveValue = Self(
    fetchCourses: { sessionCookie in
      guard let url = URL(string: "https://ilifeapp.az.tku.edu.tw/api/stu/course") else {
        throw CourseClientError.invalidURL
      }

      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue(".AspNetCore.Cookies=\(sessionCookie)", forHTTPHeaderField: "Cookie")
      request.setValue("application/json", forHTTPHeaderField: "Accept")

      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw CourseClientError.invalidResponse
      }

      switch httpResponse.statusCode {
      case 200..<300:
        return try JSONDecoder().decode([CourseSession].self, from: data)
      case 401, 403:
        throw CourseClientError.unauthorized
      default:
        throw CourseClientError.invalidResponse
      }
    }
  )

  static let testValue = Self(
    fetchCourses: { _ in [] }
  )
}

extension DependencyValues {
  var courseClient: CourseClient {
    get { self[CourseClient.self] }
    set { self[CourseClient.self] = newValue }
  }
}
