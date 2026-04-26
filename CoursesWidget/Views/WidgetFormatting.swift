import Foundation

func formattedTime(_ date: Date) -> String {
  widgetTimeFormatter.string(from: date)
}

private let widgetTimeFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.locale = .autoupdatingCurrent
  formatter.timeZone = .current
  formatter.dateFormat = "HH:mm"
  return formatter
}()
