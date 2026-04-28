import SwiftUI

struct DateSelectorView: View {
  @Binding var selectedIndex: Int
  @AppStorage(AppSettings.showWeekendDaysKey, store: AppSettings.appGroupDefaults)
  private var showWeekendDays = AppSettings.defaultShowWeekendDays()

  private let calendar: Calendar

  private var items: [Date] {
    Self.buildCurrentWeek(
      calendar: calendar,
      showWeekendDays: showWeekendDays
    )
  }

  init(selectedIndex: Binding<Int>, calendar: Calendar = Calendar(identifier: .gregorian)) {
    self._selectedIndex = selectedIndex
    var calendar = calendar
    calendar.locale = .autoupdatingCurrent
    self.calendar = calendar
  }

  var body: some View {
    HStack(spacing: 10) {
      ForEach(items.indices, id: \.self) { index in
        let date = items[index]
        let isSelected = selectedIndex == index
        let isToday = calendar.isDateInToday(date)

        Button {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedIndex = index
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
        .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 8)
    .onAppear {
      selectInitialDateIndex()
    }
    .onChange(of: showWeekendDays) {
      selectInitialDateIndex()
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

  private func selectInitialDateIndex() {
    if let index = items.firstIndex(where: { calendar.isDateInToday($0) }) {
      selectedIndex = index
      return
    }

    selectedIndex = min(selectedIndex, max(items.count - 1, 0))
  }

  static func buildCurrentWeek(
    calendar: Calendar = Calendar(identifier: .gregorian),
    showWeekendDays: Bool = true
  ) -> [Date] {
    let today = calendar.startOfDay(for: Date())
    let weekday = calendar.component(.weekday, from: today)
    let daysFromMonday = (weekday + 5) % 7
    let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today

    let fullWeek = (0..<7).compactMap { offset in
      calendar.date(byAdding: .day, value: offset, to: monday)
    }

    guard !showWeekendDays else {
      return fullWeek
    }

    return fullWeek.filter { date in
      let weekday = calendar.component(.weekday, from: date)
      return (2...6).contains(weekday)
    }
  }
}

private struct DateCell: View {
  let dayOfMonth: Int
  let weekdayText: String
  let isSelected: Bool
  let isToday: Bool

  var body: some View {
    VStack(spacing: 3) {
      Text("\(dayOfMonth)")
        .font(isSelected ? .title3.weight(.semibold) : .headline.weight(.regular))
        .foregroundStyle(isSelected ? .white : (isToday ? Color.accentColor : Color.primary))

      Text(weekdayText)
        .font(.caption)
        .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
        .accessibilityHidden(true)
    }
    .padding(EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10))
    .frame(maxWidth: .infinity, minHeight: 66)
    .background(
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .fill(isSelected ? AnyShapeStyle(Color.accentColor.opacity(0.9)) : AnyShapeStyle(.thinMaterial))
        .overlay(
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(
              !isSelected && isToday ? Color.accentColor.opacity(0.25) : Color.white.opacity(0.08),
              lineWidth: !isSelected && isToday ? 1.5 : 1
            )
        )
    )
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    .accessibilityElement(children: .combine)
  }
}

#Preview("Date Selector") {
  DateSelectorView(selectedIndex: .constant(2))
    .padding(.horizontal)
}

#Preview("Date Cell States") {
  HStack(spacing: 12) {
    DateCell(dayOfMonth: 16, weekdayText: "Mon", isSelected: true, isToday: false)
    DateCell(dayOfMonth: 17, weekdayText: "Tue", isSelected: false, isToday: true)
  }
  .padding()
}
