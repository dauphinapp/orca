import Foundation

struct DisplayedCourse: Equatable, Identifiable {
  var sessions: [CourseSession]

  var id: String {
    sessions.map(\.id).joined(separator: "-")
  }

  var week: String {
    firstSession.week
  }

  var timeText: String {
    if firstSession.id == lastSession.id {
      return "\(firstSession.sessno) \(firstSession.sesstime)"
    }

    return "\(firstSession.sessno)-\(lastSession.sessno) \(firstSession.sesstime)"
  }

  var chCosName: String {
    firstSession.chCosName
  }

  var teachName: String {
    firstSession.teachName
  }

  var room: String {
    firstSession.room
  }

  private var firstSession: CourseSession {
    sessions[0]
  }

  private var lastSession: CourseSession {
    sessions[sessions.count - 1]
  }
}

extension Array where Element == CourseSession {
  func groupedForDisplay() -> [DisplayedCourse] {
    sortedForDisplay()
      .filter(\.hasCourse)
      .reduce(into: [DisplayedCourse]()) { groupedCourses, course in
        guard
          let previousGroup = groupedCourses.last,
          let previousCourse = previousGroup.sessions.last,
          previousCourse.canMergeForDisplay(with: course)
        else {
          groupedCourses.append(DisplayedCourse(sessions: [course]))
          return
        }

        groupedCourses[groupedCourses.count - 1].sessions.append(course)
      }
  }

  private func sortedForDisplay() -> [CourseSession] {
    sorted { lhs, rhs in
      let lhsWeekNo = Int(lhs.weekno) ?? Int.max
      let rhsWeekNo = Int(rhs.weekno) ?? Int.max

      if lhsWeekNo != rhsWeekNo {
        return lhsWeekNo < rhsWeekNo
      }

      let lhsSessNo = Int(lhs.sessno) ?? Int.max
      let rhsSessNo = Int(rhs.sessno) ?? Int.max

      if lhsSessNo != rhsSessNo {
        return lhsSessNo < rhsSessNo
      }

      return lhs.sesstime < rhs.sesstime
    }
  }
}

extension CourseSession {
  fileprivate func canMergeForDisplay(with next: CourseSession) -> Bool {
    guard
      weekno == next.weekno,
      chCosName == next.chCosName,
      enCosName == next.enCosName,
      teachName == next.teachName,
      teachNameEn == next.teachNameEn,
      room == next.room,
      seatno == next.seatno,
      note == next.note,
      let currentSessionNo = Int(sessno),
      let nextSessionNo = Int(next.sessno)
    else {
      return false
    }

    return nextSessionNo == currentSessionNo + 1
  }
}
