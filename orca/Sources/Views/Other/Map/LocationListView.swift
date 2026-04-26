import SwiftUI
import UIKit

struct LocationListView: View {
  let locations: [CampusLocation]
  let didClose: () -> Void
  let didSelect: (CampusLocation) -> Void

  @State private var searchText = ""

  private var filteredLocations: [CampusLocation] {
    guard !searchText.isEmpty else {
      return locations
    }

    return locations.filter {
      $0.name.localizedCaseInsensitiveContains(searchText)
        || $0.code.localizedCaseInsensitiveContains(searchText)
    }
  }

  var body: some View {
    NavigationStack {
      List(filteredLocations) { location in
        Button {
          withAnimation(.easeInOut(duration: 0.2)) {
            didSelect(location)
          }
        } label: {
          HStack {
            Image(systemName: "building.columns.circle.fill")
              .font(.title3)
              .foregroundStyle(.tint)
            Text(verbatim: location.code == "ZZZ" ? "" : location.code)
              .font(.headline)
              .frame(
                width: UIFont.preferredFont(forTextStyle: .headline).pointSize * 2,
                alignment: .leading
              )
            Text(verbatim: location.name)
              .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
              .font(.footnote)
              .foregroundStyle(.tertiary)
          }
          .padding(2)
        }
        .accessibilityLabel(Text(verbatim: "\(location.code) \(location.name)"))
        .accessibilityHint(Text("Show location details"))
        .accessibilityIdentifier("map.location.\(location.code)")
      }
      .navigationTitle("Locations")
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(.plain)
      .searchable(text: $searchText)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: didClose) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel(Text("Close"))
          .accessibilityIdentifier("map.list.close")
        }
      }
    }
  }
}

#Preview {
  LocationListView(
    locations: CampusLocations.all,
    didClose: {},
    didSelect: { _ in }
  )
}
