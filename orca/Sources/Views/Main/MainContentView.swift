import SwiftUI

struct MainContentView: View {
  let courses: [CourseSession]
  let isLoadingCourses: Bool
  let courseErrorMessage: String?
  let cacheWarningMessage: String?
  let onTask: () async -> Void
  let onLogout: () -> Void

  var body: some View {
    TabView {
      NavigationStack {
        CourseScheduleView(
          courses: courses,
          isLoadingCourses: isLoadingCourses,
          courseErrorMessage: courseErrorMessage,
          cacheWarningMessage: cacheWarningMessage
        )
        .task {
          await onTask()
        }
      }
      .tabItem {
        Label("Courses", systemImage: "calendar")
      }

      NavigationStack {
        LibraryView()
          .navigationTitle("Library")
      }
      .tabItem {
        Label("Library", systemImage: "books.vertical")
      }

      OtherView()
      .tabItem {
        Label("Other", systemImage: "square.grid.2x2")
      }

      NavigationStack {
        SettingsView(onLogout: onLogout)
          .navigationTitle("Settings")
      }
      .tabItem {
        Label("Settings", systemImage: "gearshape")
      }
    }
  }
}

#Preview {
  MainContentView(
    courses: previewCourses,
    isLoadingCourses: false,
    courseErrorMessage: nil,
    cacheWarningMessage: nil,
    onTask: {},
    onLogout: {}
  )
}
