import SwiftUI

struct ScheduleTimelineView: View {
  let courses: [ScheduledCourse]
  var onCourseTap: (ScheduledCourse) -> Void
  var overlapGap: CGFloat = 2
  var verticalGap: CGFloat = 2

  private let calendar = Calendar.current

  private var start: Date {
    calendar.date(
      bySettingHour: 8,
      minute: 10,
      second: 0,
      of: calendar.startOfDay(for: Date())
    ) ?? Date()
  }

  private var end: Date {
    calendar.date(
      bySettingHour: 22,
      minute: 0,
      second: 0,
      of: calendar.startOfDay(for: Date())
    ) ?? Date()
  }

  private var positionedCourses: [CoursePosition] {
    let sortedCourses = courses.sorted { $0.startTime < $1.startTime }
    var groups: [[ScheduledCourse]] = []

    for course in sortedCourses {
      if let index = groups.firstIndex(where: { group in
        group.contains { coursesOverlap(course, $0) }
      }) {
        groups[index].append(course)
      } else {
        groups.append([course])
      }
    }

    var positions: [CoursePosition] = []
    for group in groups {
      var overlapSets: [[ScheduledCourse]] = []

      for course in group {
        if let index = overlapSets.firstIndex(where: { set in
          set.contains { coursesOverlap(course, $0) }
        }) {
          overlapSets[index].append(course)
        } else {
          overlapSets.append([course])
        }
      }

      for overlapSet in overlapSets {
        for (index, course) in overlapSet.enumerated() {
          positions.append(
            CoursePosition(course: course, column: index, totalColumns: overlapSet.count)
          )
        }
      }
    }

    return positions
  }

  var body: some View {
    GeometryReader { _ in
      let totalHeight = ScheduleLayout.totalHeight

      ZStack(alignment: .top) {
        TimeSlotGrid(numberOfSlots: ScheduleLayout.slotCount, totalHeight: totalHeight)

        ForEach(positionedCourses, id: \.course.id) { position in
          GeometryReader { geometry in
            let courseStart = normalized(position.course.startTime)
            let courseEnd = normalized(position.course.endTime)
            let totalWidth = geometry.size.width
            let gap = position.totalColumns == 1 ? 0 : max(0, overlapGap)
            let totalGaps = gap * CGFloat(position.totalColumns - 1)
            let availableWidth = max(0, totalWidth - totalGaps)
            let courseWidth = position.totalColumns > 0
              ? availableWidth / CGFloat(position.totalColumns)
              : totalWidth
            let xOffset = (courseWidth + gap) * CGFloat(position.column)
            let vGap = max(0, verticalGap)
            let cardHeight = max(
              0,
              heightForEvent(courseStart, courseEnd, in: totalHeight) - vGap
            )
            let yOffset = yPosition(for: courseStart, in: totalHeight) + vGap / 2

            ScheduleCourseTile(course: position.course, height: cardHeight, yOffset: yOffset)
              .frame(width: courseWidth)
              .offset(x: xOffset)
              .onTapGesture {
                onCourseTap(position.course)
              }
          }
          .frame(height: totalHeight)
        }
      }
    }
  }

  private func coursesOverlap(_ lhs: ScheduledCourse, _ rhs: ScheduledCourse) -> Bool {
    let lhsStart = normalized(lhs.startTime)
    let lhsEnd = normalized(lhs.endTime)
    let rhsStart = normalized(rhs.startTime)
    let rhsEnd = normalized(rhs.endTime)
    return lhsStart < rhsEnd && lhsEnd > rhsStart
  }

  private func normalized(_ date: Date) -> Date {
    let components = calendar.dateComponents([.hour, .minute, .second], from: date)
    return calendar.date(
      bySettingHour: components.hour ?? 0,
      minute: components.minute ?? 0,
      second: components.second ?? 0,
      of: calendar.startOfDay(for: start)
    ) ?? date
  }

  private func heightForEvent(_ startTime: Date, _ endTime: Date, in totalHeight: CGFloat) -> CGFloat {
    let totalDuration = end.timeIntervalSince(start)
    guard totalDuration > 0 else {
      return 0
    }

    let clampedStart = max(start, min(end, startTime))
    let clampedEnd = max(clampedStart, min(end, endTime))
    let eventDuration = clampedEnd.timeIntervalSince(clampedStart)
    return CGFloat(eventDuration / totalDuration) * totalHeight
  }

  private func yPosition(for time: Date, in totalHeight: CGFloat) -> CGFloat {
    let totalDuration = end.timeIntervalSince(start)
    guard totalDuration > 0 else {
      return 0
    }

    let clamped = max(start, min(end, time))
    let eventOffset = clamped.timeIntervalSince(start)
    return CGFloat(eventOffset / totalDuration) * totalHeight
  }
}

private struct CoursePosition {
  let course: ScheduledCourse
  let column: Int
  let totalColumns: Int
}

enum ScheduleLayout {
  static let startHour = 8
  static let endHour = 22
  static let slotHeight: CGFloat = 99

  static var slotCount: Int {
    endHour - startHour + 1
  }

  static var totalHeight: CGFloat {
    CGFloat(slotCount) * slotHeight
  }
}

private struct TimeSlotGrid: View {
  let numberOfSlots: Int
  let totalHeight: CGFloat

  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<numberOfSlots, id: \.self) { _ in
        Rectangle()
          .stroke(Color.gray.opacity(0.4), lineWidth: 0.3)
          .frame(height: totalHeight / CGFloat(numberOfSlots))
      }
    }
  }
}
