import CoreLocation
import Foundation

struct CampusLocation: Identifiable {
  var code: String
  var name: String
  var coordinate: CLLocationCoordinate2D

  var id: String {
    code
  }
}

enum CampusLocations {
  static let defaultCoordinate = CLLocationCoordinate2D(latitude: 25.0478, longitude: 121.5170)

  static let locations: [String: CampusLocation] = [
    "A": CampusLocation(
      code: "A",
      name: "行政大樓",
      coordinate: .init(latitude: 25.175, longitude: 121.449)
    ),
    "B": CampusLocation(
      code: "B",
      name: "商管大樓",
      coordinate: .init(latitude: 25.1765, longitude: 121.45)
    ),
    "C": CampusLocation(
      code: "C",
      name: "鍾靈化學館",
      coordinate: .init(latitude: 25.1752, longitude: 121.449)
    ),
    "E": CampusLocation(
      code: "E",
      name: "工學大樓",
      coordinate: .init(latitude: 25.1761, longitude: 121.452)
    ),
    "ED": CampusLocation(
      code: "ED",
      name: "教育大樓",
      coordinate: .init(latitude: 25.1758, longitude: 121.453)
    ),
    "F": CampusLocation(
      code: "F",
      name: "會文館",
      coordinate: .init(latitude: 25.17576, longitude: 121.44961)
    ),
    "FL": CampusLocation(
      code: "FL",
      name: "外國語文大樓",
      coordinate: .init(latitude: 25.1749, longitude: 121.452)
    ),
    "G": CampusLocation(
      code: "G",
      name: "工學館",
      coordinate: .init(latitude: 25.1763, longitude: 121.451)
    ),
    "H": CampusLocation(
      code: "H",
      name: "宮燈教室",
      coordinate: .init(latitude: 25.1746, longitude: 121.449)
    ),
    "HC": CampusLocation(
      code: "HC",
      name: "守謙國際會議中心",
      coordinate: .init(latitude: 25.1747, longitude: 121.448)
    ),
    "I": CampusLocation(
      code: "I",
      name: "覺生綜合大樓",
      coordinate: .init(latitude: 25.1743, longitude: 121.4509)
    ),
    "J": CampusLocation(
      code: "J",
      name: "麗澤國際學舍",
      coordinate: .init(latitude: 25.1763, longitude: 121.448)
    ),
    "K": CampusLocation(
      code: "K",
      name: "建築館",
      coordinate: .init(latitude: 25.17644, longitude: 121.45102)
    ),
    "L": CampusLocation(
      code: "L",
      name: "文學館",
      coordinate: .init(latitude: 25.17627, longitude: 121.44942)
    ),
    "M": CampusLocation(
      code: "M",
      name: "海事博物館",
      coordinate: .init(latitude: 25.17618, longitude: 121.45041)
    ),
    "N": CampusLocation(
      code: "N",
      name: "紹謨紀念游泳館",
      coordinate: .init(latitude: 25.1745, longitude: 121.447)
    ),
    "O": CampusLocation(
      code: "O",
      name: "傳播O館",
      coordinate: .init(latitude: 25.1756, longitude: 121.449)
    ),
    "Q": CampusLocation(
      code: "Q",
      name: "傳播Q館",
      coordinate: .init(latitude: 25.1756, longitude: 121.449)
    ),
    "R": CampusLocation(
      code: "R",
      name: "學生活動中心",
      coordinate: .init(latitude: 25.1748, longitude: 121.45)
    ),
    "S": CampusLocation(
      code: "S",
      name: "騮先紀念科學館",
      coordinate: .init(latitude: 25.1754, longitude: 121.448)
    ),
    "SG": CampusLocation(
      code: "SG",
      name: "紹謨紀念體育館",
      coordinate: .init(latitude: 25.1762, longitude: 121.449)
    ),
    "T": CampusLocation(
      code: "T",
      name: "驚聲紀念大樓",
      coordinate: .init(latitude: 25.1755, longitude: 121.451)
    ),
    "U": CampusLocation(
      code: "U",
      name: "覺生紀念圖書館",
      coordinate: .init(latitude: 25.174833, longitude: 121.450972)
    ),
    "V": CampusLocation(
      code: "V",
      name: "視聽教育館",
      coordinate: .init(latitude: 25.17503, longitude: 121.44943)
    ),
    "XC": CampusLocation(
      code: "XC",
      name: "五虎崗綜合球場",
      coordinate: .init(latitude: 25.17552, longitude: 121.45366)
    ),
    "Z": CampusLocation(
      code: "Z",
      name: "松濤館",
      coordinate: .init(latitude: 25.174967, longitude: 121.452078)
    ),
    "ZZZ": CampusLocation(
      code: "ZZZ",
      name: "書卷廣場",
      coordinate: .init(latitude: 25.17553, longitude: 121.45063)
    ),
  ]

  static let all: [CampusLocation] = locations.values.sorted { lhs, rhs in
    lhs.code.localizedStandardCompare(rhs.code) == .orderedAscending
  }

  static func coordinate(forRoom room: String) -> CLLocationCoordinate2D {
    let code = room.range(of: #"^[A-Za-z]+"#, options: .regularExpression).map {
      String(room[$0]).uppercased()
    } ?? "ZZZ"

    return locations[code]?.coordinate ?? defaultCoordinate
  }
}
