import SwiftUI

struct ScheduleCourseTile: View {
  let course: ScheduledCourse
  let height: CGFloat

  @AppStorage(AppSettings.showEnglishCourseNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishCourseName = AppSettings.defaultShowEnglishName()

  var body: some View {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .fill(.ultraThinMaterial)
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(Color.white.opacity(0.1), lineWidth: 1)
      )
      .frame(height: height)
      .overlay(alignment: .topLeading) {
        VStack(alignment: .leading, spacing: 4) {
          Text(course.displayName(showEnglish: showEnglishCourseName))
            .font(course.isShowingEnglishName(showEnglish: showEnglishCourseName) ? .footnote : .subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color(.label))
            .lineLimit(2)

          badge(systemImage: "location.circle.fill", text: course.room, color: .purple)
          badge(systemImage: "graduationcap.fill", text: course.seatNo, color: .orange)
        }
        .padding(7)
      }
      .padding(.horizontal, 2)
  }

  private func badge(systemImage: String, text: String, color: Color) -> some View {
    HStack(spacing: 3) {
      Image(systemName: systemImage)
        .font(.caption2)
        .foregroundStyle(color.opacity(0.9))
      Text(text)
        .font(.caption2)
        .foregroundStyle(.primary)
        .lineLimit(1)
    }
    .padding(.horizontal, 5)
    .padding(.vertical, 3)
    .background(
      Capsule()
        .fill(color.opacity(0.18))
    )
  }
}

#Preview {
  ScheduleCourseTile(
    course: AppPreviewData.firstScheduledCourse,
    height: 120
  )
  .padding()
}
