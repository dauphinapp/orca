import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    Group {
      if store.isLoadingSession {
        ProgressView()
          .controlSize(.large)
      } else {
        switch store.destination {
        case .onboarding:
          OnboardingView {
            store.send(.getStartedTapped)
          }

        case .login:
          LoginView(
            errorMessage: store.loginErrorMessage,
            onLoginSuccess: { cookie in
              store.send(.loginCookieReceived(cookie))
            }
          )

        case .content:
          MainContentView(
            courses: store.courses,
            isLoadingCourses: store.isLoadingCourses,
            courseErrorMessage: store.courseErrorMessage,
            cacheWarningMessage: store.cacheWarningMessage,
            onTask: {
              await store.send(.contentTask).finish()
            },
            onLogout: {
              store.send(.logoutRequested)
            }
          )
        }
      }
    }
    .task {
      await store.send(.task).finish()
    }
  }
}

#Preview {
  ContentView(
    store: Store(initialState: AppFeature.State(isLoadingSession: false)) {
      AppFeature()
    }
  )
}
