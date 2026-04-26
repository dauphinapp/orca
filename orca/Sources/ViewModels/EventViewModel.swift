import Combine
import Foundation
import OSLog

@MainActor
final class EventViewModel: ObservableObject {
  private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "cantpr09ram.dauphin", category: "EventViewModel")

  @Published private(set) var events: [CalendarEvent] = []

  func loadXMLData(term: Int) async {
    var components = URLComponents(string: AppSettings.eventCalendarEndpoint)
    components?.queryItems = [URLQueryItem(name: "t", value: String(term))]

    guard let url = components?.url else {
      Self.logger.error("Failed to build event calendar URL.")
      return
    }

    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
        Self.logger.error("Calendar API returned HTTP \(httpResponse.statusCode).")
        return
      }

      let parser = CalendarEventXMLParser(calendar: .current)
      let parsedEvents = try parser.parse(data: data)
      try Task.checkCancellation()
      events = parsedEvents
    } catch is CancellationError {
      Self.logger.debug("Cancelled event calendar request.")
    } catch {
      Self.logger.error("Failed to load event calendar: \(error.localizedDescription, privacy: .public)")
    }
  }
}
