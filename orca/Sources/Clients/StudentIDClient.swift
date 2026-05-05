import ComposableArchitecture
import Foundation

struct StudentIDClient {
  var fetchStudentID: @Sendable (_ sessionCookie: String) async throws -> String
}

enum StudentIDClientError: LocalizedError, Equatable {
  case invalidURL
  case unauthorized
  case invalidResponse
  case studentIDNotFound

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      "Invalid student ID API URL."
    case .unauthorized:
      "Session expired. Please sign in again."
    case .invalidResponse:
      "Student ID API returned an invalid response."
    case .studentIDNotFound:
      "Student ID could not be found in the response."
    }
  }
}

extension StudentIDClient: DependencyKey {
  static let liveValue = Self(
    fetchStudentID: { sessionCookie in
      guard let url = URL(string: "https://ilifeapp.az.tku.edu.tw/stu/score") else {
        throw StudentIDClientError.invalidURL
      }

      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue(".AspNetCore.Cookies=\(sessionCookie)", forHTTPHeaderField: "Cookie")
      request.setValue("text/html", forHTTPHeaderField: "Accept")

      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw StudentIDClientError.invalidResponse
      }

      switch httpResponse.statusCode {
      case 200..<300:
        return try StudentIDHTMLParser().parse(data: data)
      case 401, 403:
        throw StudentIDClientError.unauthorized
      default:
        throw StudentIDClientError.invalidResponse
      }
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
