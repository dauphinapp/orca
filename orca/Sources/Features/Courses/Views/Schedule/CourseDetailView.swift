import SwiftUI

struct CourseDetailView: View {
  let course: ScheduledCourse

  @Environment(\.dismiss) private var dismiss
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
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          detailRow(title: "Time", content: timeRange, subcontent: dayOfWeek)
          Divider()
          detailRow(title: "Location", content: course.room)
          Divider()
          detailRow(title: "Seat Number", content: course.seatNo)
          Divider()
          detailRow(
            title: "Instructor",
            content: course.displayTeacher(showEnglish: showEnglishTeacherName)
          )

          if !course.note.isEmpty {
            Divider()
            detailRow(title: "Note", content: course.note, isNote: true)
          }

          LandmarkView(coordinate: CampusLocations.coordinate(forRoom: course.room))
            .padding(.top, 8)
        }
        .padding(24)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(displayName)
            .font(.system(size: useCompactTitle ? 15 : 17, weight: .semibold))
            .lineLimit(1)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
        }
      }
    }
  }

  private func detailRow(
    title: String,
    content: String,
    subcontent: String? = nil,
    isNote: Bool = false
  ) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)

      if let subcontent {
        Text(subcontent)
          .font(.system(size: 14))
          .foregroundStyle(.secondary)
      }

      Text(content)
        .font(.system(size: isNote ? 14 : 16, weight: isNote ? .regular : .medium))
        .foregroundStyle(Color(.label))
        .fixedSize(horizontal: false, vertical: isNote)
    }
  }
}

#Preview {
  CourseDetailView(course: AppPreviewData.firstScheduledCourse)
}
