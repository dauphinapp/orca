import SwiftUI
import WidgetKit

struct CoursesNextUpHomeWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: CoursesWidgetEntry

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
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .firstTextBaseline) {
        Text("Next Up")
          .font(.headline)
        Spacer()
        Text("\(entry.todayCount) today")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      let limit = family == .systemLarge ? 4 : (family == .systemMedium ? 3 : 1)
      ForEach(Array(entry.upcomingCourses.prefix(limit).enumerated()), id: \.element.id) { index, upcoming in
        if index > 0 {
          Divider()
        }

        VStack(alignment: .leading, spacing: 3) {
          if calendarDayLabel(for: upcoming) != nil && family != .systemSmall {
            Text(calendarDayLabel(for: upcoming) ?? "")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }

          Text(upcoming.course.displayName(showEnglish: entry.showEnglishCourseName))
            .font(.system(size: courseNameFontSize(for: upcoming.course), weight: .semibold))
            .lineLimit(1)

          Text(timeRange(for: upcoming))
            .font(.caption)
            .foregroundStyle(.secondary)

          if family != .systemSmall {
            Text(upcoming.course.displayTeacher(showEnglish: entry.showEnglishTeacherName))
              .font(.caption2)
              .foregroundStyle(.secondary)
              .lineLimit(1)

            HStack(spacing: 8) {
              Label(upcoming.course.room, systemImage: "location.circle")
              if !upcoming.course.seatNo.isEmpty {
                Label(upcoming.course.seatNo, systemImage: "graduationcap")
              }
            }
            .font(.caption2)
            .lineLimit(1)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  private func widgetMessage(icon: String, title: String) -> some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: family == .systemSmall ? 42 : 52, weight: .semibold))
      Text(title)
        .font(.caption)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private func calendarDayLabel(for upcoming: UpcomingScheduledCourse) -> String? {
    guard !Calendar.current.isDate(upcoming.startDate, inSameDayAs: entry.date) else {
      return nil
    }

    return upcoming.startDate.formatted(.dateTime.weekday(.wide))
  }

  private func courseNameFontSize(for course: ScheduledCourse) -> CGFloat {
    course.isShowingEnglishName(showEnglish: entry.showEnglishCourseName) ? 12 : 14
  }

  private func timeRange(for upcoming: UpcomingScheduledCourse) -> String {
    "\(formattedTime(upcoming.startDate)) - \(formattedTime(upcoming.endDate))"
  }
}
