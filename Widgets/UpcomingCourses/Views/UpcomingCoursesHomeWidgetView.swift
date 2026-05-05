import SwiftUI
import WidgetKit

struct UpcomingCoursesHomeWidgetView: View {
  let entry: UpcomingCoursesWidgetEntry

  var body: some View {
    Group {
      if !entry.isLoggedIn {
        widgetMessage(
          icon: "person.text.rectangle.trianglebadge.exclamationmark.fill",
          title: "Sign in to see your courses"
        )
      } else if entry.upcomingCourses.isEmpty {
        widgetMessage(
          icon: "figure.wave",
          title: "No upcoming classes"
        )
      } else {
        populatedView
      }
    }
    .containerBackground(for: .widget) {
      Color(UIColor.systemBackground)
    }
  }

  private var populatedView: some View {
    let displayedCourses = Array(entry.upcomingCourses.prefix(2))

    return VStack(alignment: .leading, spacing: 6) {
      if let firstCourse = displayedCourses.first {
        courseBlock(firstCourse)
      }

      if displayedCourses.count > 1 {
        Divider()
          .padding(.leading, -8)

        let secondCourse = displayedCourses[1]
        courseBlock(
          secondCourse,
          weekdayTitle: weekdayTitleIfNeeded(current: secondCourse, previous: displayedCourses[0]),
          accentColor: isSameDay(secondCourse, as: displayedCourses[0]) ? .blue : .orange
        )
      } else {
        Color.clear
          .frame(height: 50)
      }
    }
    .padding(.leading, 10)
    .padding(.trailing, 8)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  @ViewBuilder
  private func courseBlock(
    _ upcoming: UpcomingScheduledCourse,
    weekdayTitle: String? = nil,
    accentColor: Color = .blue
  ) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      VStack(alignment: .leading, spacing: 0) {
        Text(upcoming.course.displayName(showEnglish: entry.showEnglishCourseName))
          .lineLimit(1)
          .font(.system(size: courseNameFontSize(for: upcoming.course), weight: .semibold))
          .foregroundStyle(.primary)

        Text(timeRange(for: upcoming))
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      HStack(spacing: 3) {
        infoChip(icon: "location.circle.fill", value: upcoming.course.room)
        if !upcoming.course.seatNo.isEmpty {
          infoChip(icon: "graduationcap", value: upcoming.course.seatNo)
        }
      }
    }
    .padding(.bottom, 3)
    .overlay(
      Capsule()
        .fill(accentColor)
        .frame(width: 4)
        .padding(.leading, -8),
      alignment: .leading
    )
  }

  private func widgetMessage(icon: String, title: String) -> some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 60, weight: .semibold))
      Text(title)
        .font(.caption)
        .fontWeight(.medium)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private func infoChip(icon: String, value: String) -> some View {
    HStack(spacing: 2) {
      Image(systemName: icon)
        .font(.system(size: 8))
      Text(verbatim: value)
        .font(.system(size: 10))
    }
    .lineLimit(1)
    .padding(.vertical, 2)
    .padding(.horizontal, 5)
    .background(Color.blue.opacity(0.6))
    .cornerRadius(4)
  }

  private func isSameDay(_ lhs: UpcomingScheduledCourse, as rhs: UpcomingScheduledCourse) -> Bool {
    Calendar.current.isDate(lhs.startDate, inSameDayAs: rhs.startDate)
  }

  private func weekdayTitleIfNeeded(
    current: UpcomingScheduledCourse,
    previous: UpcomingScheduledCourse
  ) -> String? {
    guard !isSameDay(current, as: previous) else {
      return nil
    }

    return current.startDate.formatted(.dateTime.weekday(.wide))
  }

  private func courseNameFontSize(for course: ScheduledCourse) -> CGFloat {
    course.isShowingEnglishName(showEnglish: entry.showEnglishCourseName) ? 12 : 15
  }

  private func timeRange(for upcoming: UpcomingScheduledCourse) -> String {
    "\(formattedTime(upcoming.startDate)) - \(formattedTime(upcoming.endDate))"
  }
}

#Preview("Home / Small Scenarios", as: .systemSmall) {
  UpcomingCoursesWidget()
} timeline: {
  UpcomingCoursesWidgetPreviewData.notLoggedIn
  UpcomingCoursesWidgetPreviewData.noUpcomingCourses
  UpcomingCoursesWidgetPreviewData.sameDayCourses
  UpcomingCoursesWidgetPreviewData.mixedDayCourses
  UpcomingCoursesWidgetPreviewData.englishNames
}
