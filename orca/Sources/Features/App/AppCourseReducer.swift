import ComposableArchitecture
import Foundation

extension AppFeature {
  func reduceContentTask(_ state: inout State) -> Effect<Action> {
    guard state.destination == .content else {
      return .none
    }

    guard !state.hasStartedCourseLoad else {
      return .none
    }

    guard let sessionCookie = state.sessionCookie, !sessionCookie.isEmpty else {
      return .send(.apiUnauthorized)
    }

    state.hasStartedCourseLoad = true
    state.isLoadingCourses = true
    state.courseErrorMessage = nil
    state.cacheWarningMessage = nil
    return .run { send in
      do {
        let courses = try await courseClient.fetchCourses(sessionCookie)
        let cache = CourseCache(updatedAt: Date(), courses: courses)
        do {
          try await courseCacheClient.save(cache)
          await widgetTimelineClient.reloadCoursesWidget()
        } catch {
          await send(.cacheSyncFailed(error.localizedDescription))
        }
        await watchCourseSyncClient.sync(cache)
        do {
          let studentID = try await studentIDClient.fetchStudentID(sessionCookie)
          let record = StudentIDRecord(updatedAt: Date(), studentID: studentID)
          try await studentIDStoreClient.save(record)
          await widgetTimelineClient.reloadStudentIDWidget()
        } catch {}
        await send(.coursesLoaded(courses))
      } catch CourseClientError.unauthorized {
        await send(.apiUnauthorized)
      } catch {
        await send(.coursesFailed(error.localizedDescription))
      }
    }
  }

  func reduceCourseResponse(
    _ state: inout State,
    _ action: Action
  ) -> Effect<Action> {
    switch action {
    case .coursesLoaded(let courses):
      state.courses = courses
      state.isLoadingCourses = false
      state.courseErrorMessage = nil
      return .none

    case .coursesFailed(let message):
      state.hasStartedCourseLoad = false
      state.isLoadingCourses = false
      state.courseErrorMessage = message
      return .none

    case .cacheSyncFailed(let message):
      state.cacheWarningMessage = message
      return .none

    case .task,
      .sessionLoadFinished,
      .contentTask,
      .getStartedTapped,
      .loginCookieReceived,
      .sessionSaved,
      .sessionSaveFailed,
      .logoutRequested,
      .sessionCleared,
      .apiUnauthorized:
      return .none
    }
  }
}
