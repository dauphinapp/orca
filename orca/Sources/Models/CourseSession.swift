import Foundation

struct CourseSession: Codable, Equatable, Identifiable {
  var weekno: String
  var sessno: String
  var week: String
  var sesstime: String
  var seatno: String
  var chCosName: String
  var enCosName: String
  var teachName: String
  var teachNameEn: String
  var note: String
  var room: String

  var id: String {
    "\(weekno)-\(sessno)"
  }

  var hasCourse: Bool {
    !chCosName.isEmpty || !enCosName.isEmpty
  }

  enum CodingKeys: String, CodingKey {
    case weekno
    case sessno
    case week
    case sesstime
    case seatno
    case chCosName = "ch_cos_name"
    case enCosName = "en_cos_name"
    case teachName = "teach_name"
    case teachNameEn = "teach_name_en"
    case note
    case room
  }
}
