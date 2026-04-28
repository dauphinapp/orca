import SwiftUI

struct SettingsView: View {
  let onLogout: () -> Void

  @AppStorage(AppSettings.showEnglishCourseNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishCourseName = AppSettings.defaultShowEnglishName()
  @AppStorage(AppSettings.showEnglishTeacherNameKey, store: AppSettings.appGroupDefaults)
  private var showEnglishTeacherName = AppSettings.defaultShowEnglishName()
  @AppStorage(AppSettings.showWeekendDaysKey, store: AppSettings.appGroupDefaults)
  private var showWeekendDays = AppSettings.defaultShowWeekendDays()

  var body: some View {
    List {
      Section {
        Toggle(isOn: $showEnglishCourseName) {
          Label("Show English Course Name", systemImage: "character.book.closed")
        }

        Toggle(isOn: $showEnglishTeacherName) {
          Label("Show English Teacher Name", systemImage: "person.text.rectangle")
        }

        Toggle(isOn: $showWeekendDays) {
          Label("Show Weekend Days", systemImage: "calendar")
        }
      } header: {
        Text("Courses")
      }

      Section {
        Button("Logout", role: .destructive) {
          onLogout()
        }
      } header: {
        Text("Account")
      }
    }
  }
}

#Preview {
  NavigationStack {
    SettingsView {}
      .navigationTitle("Settings")
  }
}
