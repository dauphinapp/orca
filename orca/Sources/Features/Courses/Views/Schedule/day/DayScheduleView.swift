import SwiftUI

struct DayScheduleView: View {
  let courses: [ScheduledCourse]
  let isLoadingCourses: Bool
  let courseErrorMessage: String?
  let cacheWarningMessage: String?

  @State private var selectedDateIndex = 0
  @AppStorage(AppSettings.showEnglishCourseNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishCourseName = AppSettings.defaultShowEnglishName()
  @AppStorage(AppSettings.showEnglishTeacherNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishTeacherName = AppSettings.defaultShowEnglishName()
  @AppStorage(AppSettings.showWeekendDaysKey, store: AppSettings.appGroupDefaults)
  private var showWeekendDays = AppSettings.defaultShowWeekendDays()

  private var monthYearText: String {
    Date.now.formatted(
      Date.FormatStyle.dateTime
        .month(.wide)
        .year(.defaultDigits)
        .locale(.autoupdatingCurrent)
    )
  }

  private var maxSelectableDateIndex: Int {
    showWeekendDays ? 6 : 4
  }

  private var selectedWeekday: Int {
    showWeekendDays ? selectedDateIndex + 1 : min(selectedDateIndex + 1, 5)
  }

  private var selectedCourses: [ScheduledCourse] {
    courses
      .filter { $0.weekday == selectedWeekday }
      .sorted { $0.startTime < $1.startTime }
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 8) {
        if let cacheWarningMessage {
          Text("Cache sync failed: \(cacheWarningMessage)")
            .font(.footnote)
            .foregroundStyle(.orange)
            .padding(.horizontal)
        }
      }
      .padding(.top, 8)

      DateSelectorView(selectedIndex: $selectedDateIndex)

      ScrollView {
        scheduleContent
      }
      .simultaneousGesture(
        DragGesture(minimumDistance: 30).onEnded { value in
          withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if value.translation.width < -50 {
              selectedDateIndex = min(selectedDateIndex + 1, maxSelectableDateIndex)
            } else if value.translation.width > 50 {
              selectedDateIndex = max(selectedDateIndex - 1, 0)
            }
          }
        }
      )
      .scrollIndicators(.hidden)
    }
    .onAppear {
      selectedDateIndex = min(selectedDateIndex, maxSelectableDateIndex)
    }
    .onChange(of: showWeekendDays) {
      selectedDateIndex = min(selectedDateIndex, maxSelectableDateIndex)
    }
  }

  @ViewBuilder
  private var scheduleContent: some View {
    if isLoadingCourses {
      VStack(spacing: 12) {
        Spacer(minLength: 120)
        ProgressView()
        Text("Loading course...")
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity)
      .padding()
    } else if let courseErrorMessage {
      VStack(spacing: 12) {
        Spacer(minLength: 120)
        Image(systemName: "exclamationmark.triangle")
          .font(.system(size: 44))
          .foregroundStyle(.red)
        Text(courseErrorMessage)
          .foregroundStyle(.red)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding()
    } else if selectedCourses.isEmpty {
      VStack(spacing: 16) {
        Spacer(minLength: 100)
        Image(systemName: "calendar.badge.exclamationmark")
          .font(.system(size: 60))
          .foregroundStyle(.secondary)
        Text("No courses for Today")
          .font(.headline)
        Text("Enjoy your free day!")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity)
      .padding()
    } else {
      LazyVStack(spacing: 12) {
        ForEach(selectedCourses) { course in
          NavigationLink {
            CourseDetailView(course: course)
          } label: {
            CourseCardView(
              courseName: course.displayName(showEnglish: showEnglishCourseName),
              useCompactCourseNameFont: course.isShowingEnglishName(
                showEnglish: showEnglishCourseName
              ),
              roomNumber: course.room,
              teacherName: course.displayTeacher(showEnglish: showEnglishTeacherName),
              startTime: course.startTime,
              endTime: course.endTime,
              seatNo: course.seatNo
            )
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
      }
      .padding(.horizontal)
      .padding(.vertical, 12)
    }
  }
}

#Preview {
  DayScheduleView(
    courses: AppPreviewData.scheduledCourses,
    isLoadingCourses: false,
    courseErrorMessage: nil,
    cacheWarningMessage: nil
  )
}
