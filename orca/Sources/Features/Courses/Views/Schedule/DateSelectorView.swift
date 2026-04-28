import SwiftUI

struct DateSelectorView: View {
  @Binding var selectedIndex: Int

  private let calendar: Calendar
  private let items: [Date]

  init(selectedIndex: Binding<Int>, calendar: Calendar = Calendar(identifier: .gregorian)) {
    self._selectedIndex = selectedIndex
    var calendar = calendar
    calendar.locale = .autoupdatingCurrent
    self.calendar = calendar
    self.items = Self.buildCurrentWeek(calendar: calendar)
  }

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(items.indices, id: \.self) { index in
            let date = items[index]
            let isSelected = selectedIndex == index
            let isToday = calendar.isDateInToday(date)

            Button {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIndex = index
                proxy.scrollTo(index, anchor: .center)
              }
            } label: {
              DateCell(
                dayOfMonth: calendar.component(.day, from: date),
                weekdayText: weekdayText(for: date),
                isSelected: isSelected,
                isToday: isToday
              )
            }
            .buttonStyle(.plain)
            .id(index)
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
      }
      .onAppear {
        if let index = items.firstIndex(where: { calendar.isDateInToday($0) }) {
          selectedIndex = index
          proxy.scrollTo(index, anchor: .center)
        }
      }
    }
  }

  private func weekdayText(for date: Date) -> String {
    let weekday = calendar.component(.weekday, from: date)
    let symbols = calendar.shortWeekdaySymbols
    guard symbols.indices.contains(weekday - 1) else {
      return ""
    }

    return symbols[weekday - 1]
  }

  static func buildCurrentWeek(calendar: Calendar = Calendar(identifier: .gregorian)) -> [Date] {
    let today = calendar.startOfDay(for: Date())
    let weekday = calendar.component(.weekday, from: today)
    let daysFromMonday = (weekday + 5) % 7
    let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today

    return (0..<7).compactMap { offset in
      calendar.date(byAdding: .day, value: offset, to: monday)
    }
  }
}

private struct DateCell: View {
  let dayOfMonth: Int
  let weekdayText: String
  let isSelected: Bool
  let isToday: Bool

  var body: some View {
    VStack(spacing: 4) {
      Text("\(dayOfMonth)")
        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
        .foregroundStyle(isSelected ? .white : (isToday ? Color.accentColor : Color.primary))

      Text(weekdayText)
        .font(.system(size: 14, weight: isSelected ? .medium : .regular))
        .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
        .accessibilityHidden(true)
    }
    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
              !isSelected && isToday ? Color.accentColor.opacity(0.3) : .clear,
              lineWidth: 2
            )
        )
        .shadow(
          color: isSelected ? Color.accentColor.opacity(0.3) : .clear,
          radius: isSelected ? 4 : 0
        )
    )
    .scaleEffect(isSelected ? 1.05 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    .accessibilityElement(children: .combine)
  }
}
