import Foundation

enum StudentIDWidgetPreviewData {
  static let signedOut = StudentIDWidgetEntry(
    date: Date(),
    state: .signedOut
  )

  static let unavailable = StudentIDWidgetEntry(
    date: Date(),
    state: .unavailable
  )

  static let ready = StudentIDWidgetEntry(
    date: Date(),
    state: .ready(studentID: "123456789")
  )
}
