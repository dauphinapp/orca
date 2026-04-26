import SwiftUI

private enum OtherSection: String, CaseIterable, Hashable {
  case calendar
  case map
}

struct OtherView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var selectedSection: OtherSection? = .calendar

  var body: some View {
    Group {
      if horizontalSizeClass == .regular {
        NavigationSplitView {
          List(selection: $selectedSection) {
            Label("Calendar", systemImage: "calendar")
              .tag(OtherSection.calendar)
            Label("Campus Map", systemImage: "map.fill")
              .tag(OtherSection.map)
          }
          .navigationTitle("Other")
          .listStyle(.sidebar)
        } detail: {
          detailView(for: selectedSection ?? .calendar)
        }
      } else {
        NavigationStack {
          List {
            NavigationLink {
              EventView()
            } label: {
              Label("Calendar", systemImage: "calendar")
            }

            NavigationLink {
              CampusMapView()
            } label: {
              Label("Campus Map", systemImage: "map.fill")
            }
          }
          .navigationTitle("Other")
        }
      }
    }
  }

  @ViewBuilder
  private func detailView(for section: OtherSection) -> some View {
    switch section {
    case .calendar:
      EventView()
    case .map:
      CampusMapView()
    }
  }
}

#Preview {
  OtherView()
}
