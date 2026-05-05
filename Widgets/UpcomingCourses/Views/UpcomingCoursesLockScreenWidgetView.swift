import SwiftUI
import WidgetKit

struct UpcomingCoursesLockScreenWidgetView: View {
  @Environment(\.colorScheme) private var colorScheme
  let entry: UpcomingCoursesWidgetEntry

  private func courseNameFontSize(for course: ScheduledCourse) -> CGFloat {
    course.isShowingEnglishName(showEnglish: entry.showEnglishCourseName) ? 13 : 15
  }

  var body: some View {
    if !entry.isLoggedIn {
      HStack(spacing: 10) {
        Image(systemName: "person.text.rectangle.trianglebadge.exclamationmark.fill")
          .font(.system(size: 40, weight: .semibold))

        Text("Sign in to see your courses")
          .font(.caption)
          .fontWeight(.medium)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .containerBackground(for: .widget) {
        Color(UIColor.systemBackground)
      }
    } else if entry.upcomingCourses.isEmpty {
      HStack(spacing: 10) {
        Image(systemName: "figure.wave")
          .font(.system(size: 40, weight: .semibold))

        Text("No upcoming classes")
          .font(.caption)
          .fontWeight(.medium)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .containerBackground(for: .widget) {
        Color(UIColor.systemBackground)
      }
    } else if let upcoming = entry.upcomingCourses.first {
      HStack(alignment: .top) {
        Rectangle()
          .fill(Color.red)
          .frame(width: 4)
          .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

        Spacer()

        VStack(alignment: .leading, spacing: 4) {
          Text(upcoming.course.displayName(showEnglish: entry.showEnglishCourseName))
            .font(.system(size: courseNameFontSize(for: upcoming.course), weight: .bold))
            .lineLimit(1)

          Text(timeRange(for: upcoming))
            .font(.system(size: 12))

          Text(upcoming.course.displayTeacher(showEnglish: entry.showEnglishTeacherName))
            .font(.system(size: 11))
            .lineLimit(1)

          HStack {
            HStack(spacing: 0) {
              Image(systemName: "location.circle")
                .resizable()
                .frame(width: 15, height: 15)
                .padding(.trailing, 6)
              Text(upcoming.course.room)
                .font(.system(size: 12))
            }

            Spacer(minLength: 20)

            HStack(spacing: 0) {
              Image(systemName: "graduationcap")
                .resizable()
                .frame(width: 15, height: 15)
                .padding(.trailing, 6)
              Text(upcoming.course.seatNo)
                .font(.system(size: 12))
            }
          }
        }
      }
      .padding(.vertical, 16)
      .padding(.horizontal,2)
      .containerBackground(for: .widget) {
        Color(UIColor.systemBackground)
      }
    } else {
      Color(UIColor.systemBackground)
    }
  }

  private func timeRange(for upcoming: UpcomingScheduledCourse) -> String {
    "\(formattedTime(upcoming.startDate)) - \(formattedTime(upcoming.endDate))"
  }

  func currentDate() -> String {
    let components = Calendar.autoupdatingCurrent.dateComponents([.month, .day], from: Date())
    let month = components.month ?? 0
    let day = components.day ?? 0
    return String(format: "%02d.%02d", month, day)
  }

  func currentDay() -> String {
    Date.now.formatted(.dateTime.weekday(.wide).locale(.autoupdatingCurrent))
  }
}

#Preview("Lock Screen / Scenarios", as: .accessoryRectangular) {
  UpcomingCoursesWidget()
} timeline: {
  UpcomingCoursesWidgetPreviewData.notLoggedIn
  UpcomingCoursesWidgetPreviewData.noUpcomingCourses
  UpcomingCoursesWidgetPreviewData.sameDayCourses
}
