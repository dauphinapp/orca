import Foundation

struct CourseCache: Codable, Equatable {
  var updatedAt: Date
  var courses: [CourseSession]
}
