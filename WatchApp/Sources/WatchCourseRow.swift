import Foundation

struct WatchCourseRow: Identifiable {
  let id: String
  let weekdayText: String
  let timeText: String
  let courseName: String
  let teacherName: String
  let room: String

  init(
    course: ScheduledCourse,
    showEnglishCourseName: Bool,
    showEnglishTeacherName: Bool,
    calendar: Calendar
  ) {
    id = course.id
    weekdayText = Self.weekdayText(for: course.weekday, calendar: calendar)
    timeText = "\(Self.timeText(for: course.startTime))-\(Self.timeText(for: course.endTime))"
    courseName = course.displayName(showEnglish: showEnglishCourseName)
    teacherName = course.displayTeacher(showEnglish: showEnglishTeacherName)
    room = course.room
  }

  private static func weekdayText(for weekday: Int, calendar: Calendar) -> String {
    guard (1...7).contains(weekday) else {
      return ""
    }

    return calendar.shortWeekdaySymbols[(weekday % 7)]
  }

  private static func timeText(for date: Date) -> String {
    date.formatted(
      Date.FormatStyle.dateTime
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
    )
  }
}
