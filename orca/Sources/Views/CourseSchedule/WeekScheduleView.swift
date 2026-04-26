import SwiftUI

struct WeekScheduleView: View {
  let courses: [ScheduledCourse]
  let isLoadingCourses: Bool
  let courseErrorMessage: String?
  let cacheWarningMessage: String?

  @State private var selectedCourse: ScheduledCourse?

  private var normalizedCurrentWeekday: Int {
    let systemWeekday = Calendar.current.component(.weekday, from: Date())
    return systemWeekday == 1 ? 7 : systemWeekday - 1
  }

  private let displayedWeekdays = Array(1...7)
  private let dayLabels = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 8) {
        if let cacheWarningMessage {
          Text("Cache sync failed: \(cacheWarningMessage)")
            .font(.footnote)
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        if isLoadingCourses {
          VStack(spacing: 12) {
            ProgressView()
            Text("Loading course...")
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let courseErrorMessage {
          ContentUnavailableView(
            "Unable to Load Courses",
            systemImage: "exclamationmark.triangle",
            description: Text(courseErrorMessage)
          )
          .foregroundStyle(.red)
        } else if courses.isEmpty {
          ContentUnavailableView(
            "No course data.",
            systemImage: "calendar.badge.exclamationmark"
          )
        } else {
          scheduleGrid(width: geometry.size.width)
        }
      }
    }
    .sheet(item: $selectedCourse) { course in
      CourseDetailView(course: course)
        .presentationDragIndicator(.visible)
    }
  }

  private func scheduleGrid(width _: CGFloat) -> some View {
    let coursesByDay = Dictionary(grouping: courses) { $0.weekday }
    let filteredCourses = displayedWeekdays.map { day in coursesByDay[day] ?? [] }

    return VStack(spacing: 0) {
      WeekdaysView(
        days: dayLabels,
        currentWeekday: normalizedCurrentWeekday
      )
      .frame(maxWidth: .infinity)

      ScrollView {
        HStack(spacing: 0) {
          ForEach(Array(filteredCourses.enumerated()), id: \.offset) { _, dayCourses in
            ScheduleTimelineView(courses: dayCourses) { course in
              selectedCourse = course
            }
            .frame(maxWidth: .infinity)
          }
        }
        .frame(maxWidth: .infinity)
      }
    }
  }
}

#Preview {
  WeekScheduleView(
    courses: previewCourses.scheduledCourses(),
    isLoadingCourses: false,
    courseErrorMessage: nil,
    cacheWarningMessage: nil
  )
}
