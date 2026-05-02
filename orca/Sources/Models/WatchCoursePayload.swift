import Foundation

struct WatchCoursePayload: Codable, Equatable {
  var cache: CourseCache
  var showEnglishCourseName: Bool
  var showEnglishTeacherName: Bool
}
