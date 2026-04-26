import Foundation

struct CalendarEventXMLParser {
  var calendar: Calendar

  init(calendar: Calendar = .current) {
    self.calendar = calendar
  }

  func parse(data: Data) throws -> [CalendarEvent] {
    let delegate = Delegate(calendar: calendar)
    let parser = XMLParser(data: data)
    parser.delegate = delegate

    guard parser.parse() else {
      throw parser.parserError ?? NSError(
        domain: "CalendarEventXMLParser",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Failed to parse event XML."]
      )
    }

    return delegate.events
  }
}

private final class Delegate: NSObject, XMLParserDelegate {
  private(set) var events: [CalendarEvent] = []

  private var currentElement = ""
  private var weekBuffer = ""
  private var dateBuffer = ""
  private var weekdayBuffer = ""
  private var eventBuffer = ""
  private var currentStartDate: Date?
  private var currentEndDate: Date?

  private let calendar: Calendar
  private let ymdFormatter: DateFormatter
  private let ymdLooseFormatter: DateFormatter
  private let mdFormatter: DateFormatter

  init(calendar: Calendar) {
    self.calendar = calendar
    ymdFormatter = Self.makeFormatter("yyyy-MM-dd", calendar: calendar)
    ymdLooseFormatter = Self.makeFormatter("yyyy-M-d", calendar: calendar)
    mdFormatter = Self.makeFormatter("MM-dd", calendar: calendar)
    super.init()
  }

  private static func makeFormatter(_ format: String, calendar: Calendar) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = calendar.timeZone
    formatter.calendar = calendar
    formatter.dateFormat = format
    return formatter
  }

  func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String] = [:]
  ) {
    currentElement = elementName
    if elementName == "cal1" || elementName == "cal" {
      weekBuffer.removeAll()
      dateBuffer.removeAll()
      weekdayBuffer.removeAll()
      eventBuffer.removeAll()
      currentStartDate = nil
      currentEndDate = nil
    }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    guard !string.isEmpty else {
      return
    }

    switch currentElement {
    case "週次":
      weekBuffer += string
    case "日期":
      dateBuffer += string
    case "星期":
      weekdayBuffer += string
    case "事項":
      eventBuffer += string
    default:
      break
    }
  }

  func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?
  ) {
    if elementName == "日期" {
      parseCurrentDates()
    }

    guard
      (elementName == "cal1" || elementName == "cal"),
      let startDate = currentStartDate,
      let endDate = currentEndDate
    else {
      return
    }

    events.append(
      CalendarEvent(
        week: weekBuffer.trimmingCharacters(in: .whitespacesAndNewlines),
        startDate: startDate,
        endDate: endDate,
        weekday: weekdayBuffer.trimmingCharacters(in: .whitespacesAndNewlines),
        event: eventBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
      )
    )
  }

  private func parseCurrentDates() {
    let normalized = dateBuffer
      .replacingOccurrences(of: "～", with: "~")
      .replacingOccurrences(of: "〜", with: "~")
      .replacingOccurrences(of: "\\s*~\\s*", with: "~", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)

    let parts = normalized.split(separator: "~", maxSplits: 1, omittingEmptySubsequences: true)
    guard
      let startValue = parts.first,
      let startDate = parseDate(
        startValue,
        fallbackYear: calendar.component(.year, from: Date())
      )
    else {
      currentStartDate = nil
      currentEndDate = nil
      return
    }

    currentStartDate = startDate
    if let endValue = parts.dropFirst().first {
      let fallbackYear = calendar.component(.year, from: startDate)
      currentEndDate = parseDate(endValue, fallbackYear: fallbackYear) ?? startDate
    } else {
      currentEndDate = startDate
    }

    if let startDate = currentStartDate, let endDate = currentEndDate, startDate > endDate {
      currentStartDate = endDate
      currentEndDate = startDate
    }
  }

  private func parseDate(_ value: Substring, fallbackYear: Int?) -> Date? {
    let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if let date = ymdFormatter.date(from: text) {
      return date
    }

    if let date = ymdLooseFormatter.date(from: text) {
      return date
    }

    guard let fallbackYear, let monthDay = mdFormatter.date(from: text) else {
      return nil
    }

    let components = calendar.dateComponents([.month, .day], from: monthDay)
    return calendar.date(
      from: DateComponents(
        calendar: calendar,
        timeZone: calendar.timeZone,
        year: fallbackYear,
        month: components.month,
        day: components.day
      )
    )
  }
}
