import SwiftUI

struct CourseCardView: View {
  let courseName: String
  let useCompactCourseNameFont: Bool
  let roomNumber: String
  let teacherName: String
  let startTime: Date
  let endTime: Date
  let seatNo: String

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 6) {
        Image(systemName: "clock.fill")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("\(startTime.scheduleTimeText) – \(endTime.scheduleTimeText)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Text(courseName)
        .font(useCompactCourseNameFont ? .headline : .title3)
        .fontWeight(.semibold)
        .foregroundStyle(.primary)
        .lineLimit(1)

      Text(teacherName)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .lineLimit(1)

      HStack(spacing: 10) {
        HStack(spacing: 5) {
          Image(systemName: "location.circle.fill")
            .font(.caption)
            .foregroundStyle(.purple.opacity(0.9))
          Text(roomNumber)
            .font(.caption)
            .foregroundStyle(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
          Capsule()
            .fill(Color.purple.opacity(0.2))
        )

        HStack(spacing: 5) {
          Image(systemName: "graduationcap.fill")
            .font(.caption)
            .foregroundStyle(.orange.opacity(0.9))
          Text(seatNo)
            .font(.caption)
            .foregroundStyle(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
          Capsule()
            .fill(Color.orange.opacity(0.2))
        )
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(Color.white.opacity(0.1), lineWidth: 1)
    )
  }
}

extension Date {
  fileprivate var scheduleTimeText: String {
    formatted(
      Date.FormatStyle.dateTime
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
    )
  }
}

#Preview {
  CourseCardView(
    courseName: AppPreviewData.firstScheduledCourse.displayName(showEnglish: false),
    useCompactCourseNameFont: false,
    roomNumber: AppPreviewData.firstScheduledCourse.room,
    teacherName: AppPreviewData.firstScheduledCourse.displayTeacher(showEnglish: false),
    startTime: AppPreviewData.firstScheduledCourse.startTime,
    endTime: AppPreviewData.firstScheduledCourse.endTime,
    seatNo: AppPreviewData.firstScheduledCourse.seatNo
  )
  .padding()
}
