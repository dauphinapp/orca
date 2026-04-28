import SwiftUI

struct CourseScheduleView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let courses: [CourseSession]
  let isLoadingCourses: Bool
  let courseErrorMessage: String?
  let cacheWarningMessage: String?

  private var scheduledCourses: [ScheduledCourse] {
    courses.scheduledCourses()
  }

  var body: some View {
    Group {
      if horizontalSizeClass == .compact {
        DayScheduleView(
          courses: scheduledCourses,
          isLoadingCourses: isLoadingCourses,
          courseErrorMessage: courseErrorMessage,
          cacheWarningMessage: cacheWarningMessage
        )
      } else {
        WeekScheduleView(
          courses: scheduledCourses,
          isLoadingCourses: isLoadingCourses,
          courseErrorMessage: courseErrorMessage,
          cacheWarningMessage: cacheWarningMessage
        )
        .padding(.horizontal, 15)
      }
    }
  }
}

#Preview {
  CourseScheduleView(
    courses: AppPreviewData.courseSessions,
    isLoadingCourses: false,
    courseErrorMessage: nil,
    cacheWarningMessage: nil
  )
}
