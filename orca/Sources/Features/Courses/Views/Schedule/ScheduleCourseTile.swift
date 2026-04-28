import SwiftUI

struct ScheduleCourseTile: View {
  let course: ScheduledCourse
  let height: CGFloat
  let yOffset: CGFloat

  @AppStorage(AppSettings.showEnglishCourseNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishCourseName = AppSettings.defaultShowEnglishName()

  private var courseNameFontSize: CGFloat {
    course.isShowingEnglishName(showEnglish: showEnglishCourseName) ? 13 : 15
  }

  var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(Color(.secondarySystemBackground))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color(.separator), lineWidth: 1)
      )
      .frame(height: height)
      .overlay(alignment: .topLeading) {
        VStack(alignment: .leading, spacing: 3) {
          Text(course.displayName(showEnglish: showEnglishCourseName))
            .font(.system(size: courseNameFontSize, weight: .semibold))
            .foregroundStyle(Color(.label))
            .lineLimit(2)

          badge(systemImage: "location.circle.fill", text: course.room, color: .purple)
          badge(systemImage: "graduationcap.fill", text: course.seatNo, color: .orange)
        }
        .padding(8)
      }
      .offset(y: yOffset)
      .padding(.horizontal, 2)
  }

  private func badge(systemImage: String, text: String, color: Color) -> some View {
    HStack(spacing: 2) {
      Image(systemName: systemImage)
        .font(.system(size: 10))
        .foregroundStyle(color)
      Text(text)
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(.primary)
        .lineLimit(1)
    }
    .padding(.horizontal, 4)
    .padding(.vertical, 2)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(color.opacity(0.15))
    )
  }
}

#Preview {
  ScheduleCourseTile(
    course: AppPreviewData.firstScheduledCourse,
    height: 120,
    yOffset: 8
  )
  .padding()
}
