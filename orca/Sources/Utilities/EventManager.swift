import EventKit

@MainActor
final class EventManager {
  let eventStore = EKEventStore()

  func requestWriteAccess() async -> Bool {
    guard #available(iOS 17, *) else {
      return await withCheckedContinuation { continuation in
        eventStore.requestAccess(to: .event) { granted, _ in
          continuation.resume(returning: granted)
        }
      }
    }

    return await withCheckedContinuation { continuation in
      eventStore.requestWriteOnlyAccessToEvents { granted, _ in
        continuation.resume(returning: granted)
      }
    }
  }

  func makeEKEvent(from event: CalendarEvent) -> EKEvent? {
    guard
      let calendar = eventStore.defaultCalendarForNewEvents
        ?? eventStore.calendars(for: .event).first
    else {
      return nil
    }

    let ekEvent = EKEvent(eventStore: eventStore)
    ekEvent.title = event.event
    ekEvent.startDate = event.startDate
    ekEvent.endDate = event.endDate
    ekEvent.isAllDay = Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate)
    ekEvent.calendar = calendar
    return ekEvent
  }
}
