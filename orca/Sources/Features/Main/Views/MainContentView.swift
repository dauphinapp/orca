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
        .navigationTitle("Courses")
        .toolbarTitleDisplayMode(.inlineLarge)
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
          .toolbarTitleDisplayMode(.inlineLarge)
      }
      .tabItem {
        Label("Library", systemImage: "books.vertical")
      }
      NavigationStack {
        OtherView()
          .navigationTitle("Other")
          .toolbarTitleDisplayMode(.inlineLarge)
      }
      .tabItem {
        Label("Other", systemImage: "square.grid.2x2")
      }

      NavigationStack {
        SettingsView(onLogout: onLogout)
          .navigationTitle("Settings")
          .toolbarTitleDisplayMode(.inlineLarge)
      }
      .tabItem {
        Label("Settings", systemImage: "gearshape")
      }
    }
  }
}

#Preview {
  MainContentView(
    courses: AppPreviewData.courseSessions,
    isLoadingCourses: false,
    courseErrorMessage: nil,
    cacheWarningMessage: nil,
    onTask: {},
    onLogout: {}
  )
}
