import SwiftUI

struct CourseDetailView: View {
  let course: ScheduledCourse

  @AppStorage(AppSettings.showEnglishCourseNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishCourseName = AppSettings.defaultShowEnglishName()
  @AppStorage(AppSettings.showEnglishTeacherNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishTeacherName = AppSettings.defaultShowEnglishName()

  private var displayName: String {
    course.displayName(showEnglish: showEnglishCourseName)
  }

  private var useCompactTitle: Bool {
    course.isShowingEnglishName(showEnglish: showEnglishCourseName)
  }

  private var dayOfWeek: String {
    let calendar = Calendar.current
    var symbols = calendar.weekdaySymbols
    let sunday = symbols.removeFirst()
    symbols.append(sunday)
    guard symbols.indices.contains(course.weekday - 1) else {
      return ""
    }

    return symbols[course.weekday - 1]
  }

  private var timeRange: String {
    "\(Self.timeFormatter.string(from: course.startTime)) - \(Self.timeFormatter.string(from: course.endTime))"
  }

  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
  }()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading, spacing: 20) {
          detailRow(title: "Time", content: timeRange, subcontent: dayOfWeek)
          detailRow(title: "Location", content: course.room)
          detailRow(title: "Seat Number", content: course.seatNo)
          detailRow(
            title: "Instructor",
            content: course.displayTeacher(showEnglish: showEnglishTeacherName)
          )

          if !course.note.isEmpty {
            detailRow(title: "Note", content: course.note, isNote: true)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

        LandmarkView(coordinate: CampusLocations.coordinate(forRoom: course.room))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top, 8)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
    }
    .background(Color(.systemGroupedBackground).ignoresSafeArea())
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(displayName)
          .font(useCompactTitle ? .subheadline : .headline)
          .fontWeight(.semibold)
          .lineLimit(1)
      }
    }
  }

  private func detailRow(
    title: String,
    content: String,
    subcontent: String? = nil,
    isNote: Bool = false
  ) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)

      if let subcontent {
        Text(subcontent)
          .font(.system(size: 14))
          .foregroundStyle(.secondary)
      }

      Text(content)
        .font(isNote ? .footnote : .body)
        .fontWeight(isNote ? .regular : .semibold)
        .foregroundStyle(Color(.label))
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

#Preview {
  NavigationStack {
    CourseDetailView(course: AppPreviewData.firstScheduledCourse)
  }
}
