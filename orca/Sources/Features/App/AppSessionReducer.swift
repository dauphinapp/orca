import ComposableArchitecture
import Foundation

extension AppFeature {
  func reduceSession(
    _ state: inout State,
    _ action: Action
  ) -> Effect<Action> {
    switch action {
    case .task:
      guard !state.hasStartedSessionLoad else {
        return .none
      }

      state.hasStartedSessionLoad = true
      state.isLoadingSession = true
      return .run { send in
        let sessionCookie = await authClient.loadSessionCookie()
        await send(.sessionLoadFinished(sessionCookie: sessionCookie))
      }

    case .sessionLoadFinished(let sessionCookie):
      state.isLoadingSession = false
      state.loginErrorMessage = nil
      state.sessionCookie = sessionCookie
      AppSettings.appGroupDefaults.set(sessionCookie?.isEmpty == false, forKey: AppSettings.widgetIsLoggedInKey)

      if sessionCookie?.isEmpty == false {
        state.destination = .content
      } else {
        state.destination = .onboarding
      }
      return syncCachedCoursesToWatch()

    case .getStartedTapped:
      state.destination = .login
      state.loginErrorMessage = nil
      return .none

    case .loginCookieReceived(let cookie):
      guard state.destination == .login else {
        return .none
      }

      guard !cookie.isEmpty else {
        return .none
      }

      state.loginErrorMessage = nil
      return .run { send in
        do {
          try await authClient.saveSessionCookie(cookie)
          await send(.sessionSaved(cookie))
        } catch {
          await send(.sessionSaveFailed(error.localizedDescription))
        }
      }

    case .sessionSaved(let sessionCookie):
      state.destination = .content
      state.sessionCookie = sessionCookie
      state.hasStartedCourseLoad = false
      state.loginErrorMessage = nil
      AppSettings.appGroupDefaults.set(true, forKey: AppSettings.widgetIsLoggedInKey)
      return syncCachedCoursesToWatch()

    case .sessionSaveFailed(let message):
      state.destination = .login
      state.loginErrorMessage = message
      return .none

    case .logoutRequested, .apiUnauthorized:
      clearSessionState(&state)
      AppSettings.appGroupDefaults.set(false, forKey: AppSettings.widgetIsLoggedInKey)
      return .run { send in
        try? await authClient.clearSessionCookie()
        try? await courseCacheClient.clear()
        try? await studentIDStoreClient.clear()
        await watchCourseSyncClient.sync(CourseCache(updatedAt: Date(), courses: []))
        await widgetTimelineClient.reloadWidgets()
        await widgetTimelineClient.reloadStudentIDWidget()
        await send(.sessionCleared)
      }

    case .contentTask,
      .coursesLoaded,
      .coursesFailed,
      .cacheSyncFailed,
      .sessionCleared:
      return .none
    }
  }

  private func clearSessionState(_ state: inout State) {
    state.destination = .onboarding
    state.sessionCookie = nil
    state.hasStartedCourseLoad = false
    state.isLoadingCourses = false
    state.loginErrorMessage = nil
    state.courseErrorMessage = nil
    state.cacheWarningMessage = nil
    state.courses = []
  }

  private func syncCachedCoursesToWatch() -> Effect<Action> {
    .run { _ in
      guard let cache = try? await courseCacheClient.load() else {
        return
      }

      await watchCourseSyncClient.sync(cache)
    }
  }
}
