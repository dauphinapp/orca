import SwiftUI

struct CourseListView: View {
  let courses: [CourseSession]
  let isLoadingCourses: Bool
  let courseErrorMessage: String?
  let cacheWarningMessage: String?

  private var scheduledCourses: [DisplayedCourse] {
    courses.groupedForDisplay()
  }

  var body: some View {
    List {
      Section {
        if let cacheWarningMessage {
          Text("Cache sync failed: \(cacheWarningMessage)")
            .font(.footnote)
            .foregroundStyle(.orange)
        }

        if isLoadingCourses {
          HStack {
            ProgressView()
            Text("Loading course...")
          }
        } else if let courseErrorMessage {
          Text(courseErrorMessage)
            .foregroundStyle(.red)
        } else if scheduledCourses.isEmpty {
          Text("No course data.")
            .foregroundStyle(.secondary)
        } else {
          ForEach(scheduledCourses) { course in
            VStack(alignment: .leading, spacing: 6) {
              Text("\(course.week) \(course.timeText)")
                .font(.caption)
                .foregroundStyle(.secondary)

              Text(course.chCosName)
                .font(.headline)

              Text("\(course.teachName) / \(course.room)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
          }
        }
      } header: {
        Text("Course API")
      }
    }
  }
}

let previewCourses = [
  CourseSession(
    weekno: "1",
    sessno: "06",
    week: "一",
    sesstime: "13:10",
    seatno: "009",
    chCosName: "模糊理論",
    enCosName: "FUZZY THEORY",
    teachName: "翁慶昌",
    teachNameEn: "WONG CHING-CHANG",
    note: "",
    room: "E  414"
  ),
  CourseSession(
    weekno: "1",
    sessno: "07",
    week: "一",
    sesstime: "14:10",
    seatno: "009",
    chCosName: "模糊理論",
    enCosName: "FUZZY THEORY",
    teachName: "翁慶昌",
    teachNameEn: "WONG CHING-CHANG",
    note: "",
    room: "E  414"
  ),
]

#Preview {
  CourseListView(
    courses: previewCourses,
    isLoadingCourses: false,
    courseErrorMessage: nil,
    cacheWarningMessage: nil
  )
}
