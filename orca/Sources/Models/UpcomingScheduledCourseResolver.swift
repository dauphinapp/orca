import Foundation

struct UpcomingScheduledCourse: Equatable, Identifiable {
  var course: ScheduledCourse
  var startDate: Date
  var endDate: Date

  var id: String {
    "\(course.id)-\(startDate.timeIntervalSince1970)"
  }
}

struct UpcomingScheduledCourseResolver {
  var calendar: Calendar = .current
  var upcomingThreshold: TimeInterval = 20 * 60

  func upcomingCourses(
    from courses: [ScheduledCourse],
    now: Date = Date(),
    limit: Int = 5
  ) -> [UpcomingScheduledCourse] {
    courses
      .compactMap { upcomingOccurrence(for: $0, now: now) }
      .sorted { lhs, rhs in
        if lhs.startDate != rhs.startDate {
          return lhs.startDate < rhs.startDate
        }

        return lhs.course.displayName(showEnglish: false) < rhs.course.displayName(showEnglish: false)
      }
      .prefix(limit)
      .map { $0 }
  }

  private func upcomingOccurrence(
    for course: ScheduledCourse,
    now: Date
  ) -> UpcomingScheduledCourse? {
    guard
      let startDate = scheduledDate(for: course.startTime, weekday: course.weekday, relativeTo: now),
      let endDate = scheduledDate(for: course.endTime, weekday: course.weekday, relativeTo: now)
    else {
      return nil
    }

    var adjustedStartDate = startDate
    var adjustedEndDate = endDate

    if adjustedEndDate.timeIntervalSince(now) <= upcomingThreshold {
      adjustedStartDate = calendar.date(byAdding: .day, value: 7, to: adjustedStartDate) ?? adjustedStartDate
      adjustedEndDate = calendar.date(byAdding: .day, value: 7, to: adjustedEndDate) ?? adjustedEndDate
    }

    return UpcomingScheduledCourse(course: course, startDate: adjustedStartDate, endDate: adjustedEndDate)
  }

  private func scheduledDate(for template: Date, weekday: Int, relativeTo now: Date) -> Date? {
    guard let targetWeekday = calendarWeekday(fromWeekday: weekday) else {
      return nil
    }

    let currentWeekday = calendar.component(.weekday, from: now)
    let daysUntilCourse = (targetWeekday - currentWeekday + 7) % 7
    guard let targetDate = calendar.date(byAdding: .day, value: daysUntilCourse, to: now) else {
      return nil
    }

    let components = calendar.dateComponents([.hour, .minute], from: template)
    return calendar.date(
      bySettingHour: components.hour ?? 0,
      minute: components.minute ?? 0,
      second: 0,
      of: targetDate
    )
  }

  private func calendarWeekday(fromWeekday weekday: Int) -> Int? {
    guard (1...7).contains(weekday) else {
      return nil
    }

    return weekday == 7 ? 1 : weekday + 1
  }
}
