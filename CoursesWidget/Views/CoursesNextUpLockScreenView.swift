import SwiftUI
import WidgetKit

struct CoursesNextUpLockScreenView: View {
  let entry: CoursesWidgetEntry

  var body: some View {
    Group {
      if !entry.isLoggedIn {
        Text("Sign in to see your courses")
          .font(.caption)
      } else if let upcoming = entry.upcomingCourses.first {
        HStack(alignment: .top, spacing: 10) {
          Rectangle()
            .fill(Color.red)
            .frame(width: 4)
            .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

          VStack(alignment: .leading, spacing: 4) {
            Text(upcoming.course.displayName(showEnglish: entry.showEnglishCourseName))
              .font(.system(size: 14, weight: .bold))
              .lineLimit(1)
            Text(timeRange(for: upcoming))
              .font(.system(size: 12))
            Text(upcoming.course.displayTeacher(showEnglish: entry.showEnglishTeacherName))
              .font(.system(size: 11))
              .lineLimit(1)
          }
        }
      } else {
        Text("No upcoming classes")
          .font(.caption)
      }
    }
    .containerBackground(for: .widget) {
      Color(UIColor.systemBackground)
    }
  }

  private func timeRange(for upcoming: UpcomingScheduledCourse) -> String {
    "\(formattedTime(upcoming.startDate)) - \(formattedTime(upcoming.endDate))"
  }
}
