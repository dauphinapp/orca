import ComposableArchitecture
import SwiftUI

@main
struct OrcaApp: App {
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  var body: some Scene {
    WindowGroup {
      ContentView(store: Self.store)
    }
  }
}
