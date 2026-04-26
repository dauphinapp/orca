import ComposableArchitecture
import Foundation

extension AppFeature {
  @ObservableState
  struct State: Equatable {
    enum Destination: Equatable {
      case onboarding
      case login
      case content
    }

    var destination: Destination = .onboarding
    var sessionCookie: String?
    var hasStartedSessionLoad = false
    var hasStartedCourseLoad = false
    var isLoadingSession = true
    var isLoadingCourses = false
    var loginErrorMessage: String?
    var courseErrorMessage: String?
    var cacheWarningMessage: String?
    var courses: [CourseSession] = []
  }

  enum Action: Equatable {
    case task
    case sessionLoadFinished(sessionCookie: String?)
    case contentTask
    case getStartedTapped
    case loginCookieReceived(String)
    case sessionSaved(String)
    case sessionSaveFailed(String)
    case coursesLoaded([CourseSession])
    case coursesFailed(String)
    case cacheSyncFailed(String)
    case logoutRequested
    case sessionCleared
    case apiUnauthorized
  }
}
