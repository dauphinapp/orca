import Foundation

enum AppPreviewData {
  static let courseSessions: [CourseSession] = [
    CourseSession(
      weekno: "1",
      sessno: "06",
      week: "一",
      sesstime: "13:10",
      seatno: "009",
      chCosName: "模糊理論",
      enCosName: "FUZZY THEORY",
      teachName: "翁慶昌",
      teachNameEn: "WONG CHING-CHANG",
      note: "",
      room: "E 414"
    ),
    CourseSession(
      weekno: "1",
      sessno: "07",
      week: "一",
      sesstime: "14:10",
      seatno: "009",
      chCosName: "模糊理論",
      enCosName: "FUZZY THEORY",
      teachName: "翁慶昌",
      teachNameEn: "WONG CHING-CHANG",
      note: "",
      room: "E 414"
    ),
    CourseSession(
      weekno: "2",
      sessno: "03",
      week: "二",
      sesstime: "10:10",
      seatno: "016",
      chCosName: "資料結構",
      enCosName: "DATA STRUCTURES",
      teachName: "林教授",
      teachNameEn: "PROF. LIN",
      note: "",
      room: "B 713"
    ),
    CourseSession(
      weekno: "2",
      sessno: "04",
      week: "二",
      sesstime: "11:10",
      seatno: "016",
      chCosName: "資料結構",
      enCosName: "DATA STRUCTURES",
      teachName: "林教授",
      teachNameEn: "PROF. LIN",
      note: "",
      room: "B 713"
    ),
  ]

  static let scheduledCourses: [ScheduledCourse] = courseSessions.scheduledCourses()

  static let firstScheduledCourse: ScheduledCourse = scheduledCourses.first
    ?? ScheduledCourse(
      id: "preview-fallback",
      name: "課程預覽",
      enName: "PREVIEW COURSE",
      teacher: "教師",
      teacherEn: "INSTRUCTOR",
      room: "A 101",
      seatNo: "001",
      note: "",
      weekday: 1,
      sessionNumbers: [1],
      startTime: Date(),
      endTime: Date().addingTimeInterval(50 * 60)
    )

  static let mondayCourses: [ScheduledCourse] = {
    let filtered = scheduledCourses.filter { $0.weekday == 1 }
    return filtered.isEmpty ? [firstScheduledCourse] : filtered
  }()
}
