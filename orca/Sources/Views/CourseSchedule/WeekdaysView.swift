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
      .font(.system(size: 12, weight: isToday ? .semibold : .medium))
      .foregroundStyle(isToday ? Color.blue : Color(.tertiaryLabel))
      .frame(maxWidth: .infinity, minHeight: 20)
  }
}
