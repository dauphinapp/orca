import Foundation

struct NextCourse: Equatable {
  var course: CourseSession
  var startDate: Date
}

struct NextCourseResolver {
  var calendar: Calendar = .current

  func nextCourse(from courses: [CourseSession], now: Date = Date()) -> NextCourse? {
    courses
      .filter(\.hasCourse)
      .compactMap { course -> NextCourse? in
        guard let startDate = startDate(for: course, relativeTo: now) else {
          return nil
        }

        return NextCourse(course: course, startDate: startDate)
      }
      .min { $0.startDate < $1.startDate }
  }

  private func startDate(for course: CourseSession, relativeTo now: Date) -> Date? {
    guard
      let targetWeekday = calendarWeekday(fromWeekNo: course.weekno),
      let time = parseTime(course.sesstime)
    else {
      return nil
    }

    let currentWeekday = calendar.component(.weekday, from: now)
    let daysUntilCourse = (targetWeekday - currentWeekday + 7) % 7

    guard
      let targetDay = calendar.date(byAdding: .day, value: daysUntilCourse, to: now),
      var startDate = calendar.date(
        bySettingHour: time.hour,
        minute: time.minute,
        second: 0,
        of: targetDay
      )
    else {
      return nil
    }

    if startDate <= now {
      guard let nextWeekDate = calendar.date(byAdding: .day, value: 7, to: startDate) else {
        return nil
      }
      startDate = nextWeekDate
    }

    return startDate
  }

  private func calendarWeekday(fromWeekNo weekNo: String) -> Int? {
    guard let value = Int(weekNo), (1...7).contains(value) else {
      return nil
    }

    return value == 7 ? 1 : value + 1
  }

  private func parseTime(_ value: String) -> (hour: Int, minute: Int)? {
    let parts = value.split(separator: ":")
    guard
      parts.count == 2,
      let hour = Int(parts[0]),
      let minute = Int(parts[1])
    else {
      return nil
    }

    return (hour, minute)
  }
}
