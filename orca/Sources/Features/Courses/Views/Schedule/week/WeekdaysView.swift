import SwiftUI

struct WeekdaysView: View {
  let days: [String]
  let currentWeekday: Int

  var body: some View {
    HStack(spacing: 0) {
      ForEach(days.indices, id: \.self) { index in
        weekdayCell(index: index)
      }
    }
  }

  private func weekdayCell(index: Int) -> some View {
    let label = days[index]
    let weekdayValue = index + 1
    let isToday = weekdayValue == currentWeekday

    return Text(label)
      .font(.caption)
      .fontWeight(isToday ? .semibold : .regular)
      .foregroundStyle(isToday ? Color.accentColor : Color.secondary)
      .frame(maxWidth: .infinity, minHeight: 22)
  }
}

#Preview {
  WeekdaysView(days: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"], currentWeekday: 2)
    .padding()
}
