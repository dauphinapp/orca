import EventKit
import SwiftUI

struct EventView: View {
  @StateObject private var viewModel = EventViewModel()
  private let eventManager = EventManager()

  @State private var term = ([8, 9, 10, 11, 12, 1].contains(Calendar.current.component(.month, from: Date())) ? 1 : 2)
  @State private var editorItem: EditItem?
  @State private var addToCalendarTask: Task<Void, Never>?

  struct EditItem: Identifiable {
    let id = UUID()
    let event: EKEvent
  }

  var body: some View {
    List {
      ForEach(viewModel.events) { event in
        HStack(alignment: .top, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text(event.event)
              .font(.headline)
            Text(dateRangeText(for: event))
              .font(.footnote)
              .foregroundStyle(.secondary)
          }

          Spacer(minLength: 12)

          Button {
            addEventToSystemCalendar(event)
          } label: {
            Label("Add to Calendar", systemImage: "calendar.badge.plus")
              .labelStyle(.iconOnly)
              .font(.system(size: 16, weight: .semibold))
              .padding(10)
              .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                  .fill(Color.blue.opacity(0.15))
              )
          }
          .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
      }
    }
    .navigationTitle("校務行事曆")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          term = term == 1 ? 2 : 1
        } label: {
          Image(systemName: term == 1 ? "chevron.down" : "chevron.up")
        }
      }
    }
    .sheet(item: $editorItem) { item in
      EventEditSheet(eventStore: eventManager.eventStore, event: item.event)
    }
    .task(id: term) {
      await viewModel.loadXMLData(term: term)
    }
    .refreshable {
      await viewModel.loadXMLData(term: term)
    }
    .onDisappear {
      addToCalendarTask?.cancel()
      addToCalendarTask = nil
    }
  }

  private func addEventToSystemCalendar(_ event: CalendarEvent) {
    addToCalendarTask?.cancel()
    addToCalendarTask = Task { @MainActor in
      let hasAccess = await eventManager.requestWriteAccess()
      guard !Task.isCancelled, hasAccess else {
        return
      }

      if let ekEvent = eventManager.makeEKEvent(from: event) {
        editorItem = EditItem(event: ekEvent)
      }
    }
  }

  private func dateRangeText(for event: CalendarEvent) -> String {
    if Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate) {
      return event.startDate.formatted(Self.dateFormat)
    }

    return "\(event.startDate.formatted(Self.dateFormat))\n- \(event.endDate.formatted(Self.dateFormat))"
  }

  private static let dateFormat = Date.FormatStyle(
    date: .none,
    time: .none,
    locale: .autoupdatingCurrent
  )
  .year(.defaultDigits)
  .month(.wide)
  .day(.defaultDigits)
  .weekday(.wide)
}

#Preview {
  NavigationStack {
    EventView()
  }
}
