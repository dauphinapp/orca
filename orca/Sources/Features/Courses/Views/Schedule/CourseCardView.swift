import SwiftUI

struct CourseCardView: View {
  let courseName: String
  let useCompactCourseNameFont: Bool
  let roomNumber: String
  let teacherName: String
  let startTime: Date
  let endTime: Date
  let seatNo: String

  private var courseNameFontSize: CGFloat {
    useCompactCourseNameFont ? 18 : 20
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack {
        HStack {
          Image(systemName: "clock.fill")
            .font(.system(size: 11))
          Text("\(startTime.scheduleTimeText) - \(endTime.scheduleTimeText)")
            .font(.system(size: 11, weight: .medium))
        }
        .padding(.vertical, 4)
        .clipShape(Capsule())
      }

      Text(courseName)
        .font(.system(size: courseNameFontSize, weight: .semibold))
        .foregroundStyle(.primary)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)

      HStack(spacing: 8) {
        HStack(spacing: 4) {
          Image(systemName: "location.circle.fill")
            .font(.system(size: 12))
            .foregroundStyle(.purple)
          Text(roomNumber)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.primary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.purple.opacity(0.15))
        )

        HStack(spacing: 4) {
          Image(systemName: "graduationcap.fill")
            .font(.system(size: 12))
            .foregroundStyle(.orange)
          Text(seatNo)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.primary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange.opacity(0.15))
        )

        Spacer()

        HStack(spacing: 4) {
          Image(systemName: "person.fill")
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
          Text(teacherName)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
      }
    }
    .padding(15)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color(.systemBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
