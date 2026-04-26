import SwiftUI

struct LibraryView: View {
  var body: some View {
    ContentUnavailableView("Library", systemImage: "books.vertical")
  }
}

#Preview {
  NavigationStack {
    LibraryView()
      .navigationTitle("Library")
  }
}
