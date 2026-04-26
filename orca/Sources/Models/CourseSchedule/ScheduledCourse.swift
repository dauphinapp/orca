import Foundation

struct ScheduledCourse: Equatable, Identifiable {
  var id: String
  var name: String
  var enName: String
  var teacher: String
  var teacherEn: String
  var room: String
  var seatNo: String
  var note: String
  var weekday: Int
  var sessionNumbers: [Int]
  var startTime: Date
  var endTime: Date

  func isShowingEnglishName(showEnglish: Bool) -> Bool {
    showEnglish && !enName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  func displayName(showEnglish: Bool) -> String {
    isShowingEnglishName(showEnglish: showEnglish) ? enName : name
  }

  func displayTeacher(showEnglish: Bool) -> String {
    if showEnglish && !teacherEn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return teacherEn
    }

    return teacher
  }
}

extension Array where Element == CourseSession {
  func scheduledCourses(calendar: Calendar = .current) -> [ScheduledCourse] {
    groupedForDisplay()
      .compactMap { ScheduledCourse(displayedCourse: $0, calendar: calendar) }
      .sorted { lhs, rhs in
        if lhs.weekday != rhs.weekday {
          return lhs.weekday < rhs.weekday
        }

        return lhs.startTime < rhs.startTime
      }
  }
}

extension ScheduledCourse {
  init?(displayedCourse: DisplayedCourse, calendar: Calendar = .current) {
    guard
      let firstSession = displayedCourse.sessions.first,
      let lastSession = displayedCourse.sessions.last,
      let weekday = Int(firstSession.weekno),
      (1...7).contains(weekday),
      let startTime = Self.time(from: firstSession.sesstime, calendar: calendar)
    else {
      return nil
    }

    let endTime: Date
    if let lastSessionNumber = Int(lastSession.sessno),
      let mappedEndTime = Self.endTime(forSession: lastSessionNumber, calendar: calendar)
    {
      endTime = mappedEndTime
    } else {
      endTime = calendar.date(byAdding: .minute, value: 50, to: startTime) ?? startTime
    }

    self.init(
      id: displayedCourse.id,
      name: firstSession.chCosName,
      enName: firstSession.enCosName,
      teacher: firstSession.teachName,
      teacherEn: firstSession.teachNameEn,
      room: firstSession.room,
      seatNo: firstSession.seatno,
      note: firstSession.note,
      weekday: weekday,
      sessionNumbers: displayedCourse.sessions.compactMap { Int($0.sessno) },
      startTime: startTime,
      endTime: max(endTime, startTime)
    )
  }

  static func time(from value: String, calendar: Calendar = .current) -> Date? {
    let parts = value.split(separator: ":")
    guard
      parts.count == 2,
      let hour = Int(parts[0]),
      let minute = Int(parts[1])
    else {
      return nil
    }

    return calendar.date(
      bySettingHour: hour,
      minute: minute,
      second: 0,
      of: calendar.startOfDay(for: Date())
    )
  }

  static func endTime(forSession session: Int, calendar: Calendar = .current) -> Date? {
    let endHour = [
      1: 9,
      2: 10,
      3: 11,
      4: 12,
      5: 13,
      6: 14,
      7: 15,
      8: 16,
      9: 17,
      10: 18,
      11: 19,
      12: 20,
      13: 21,
      14: 22,
    ][session]

    guard let endHour else {
      return nil
    }

    return calendar.date(
      bySettingHour: endHour,
      minute: 0,
      second: 0,
      of: calendar.startOfDay(for: Date())
    )
  }
}
