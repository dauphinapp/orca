import SwiftUI

struct MarkerSheetView: View {
  let location: CampusLocation
  let didClearSelection: () -> Void
  let didReturnToList: () -> Void

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text(location.code)
            .font(.subheadline)
            .foregroundStyle(.secondary)

          LandmarkView(coordinate: location.coordinate)

          Button(action: didReturnToList) {
            Label("Return to List", systemImage: "list.bullet")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
          .accessibilityIdentifier("map.action.returnList")
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
      }
      .navigationTitle(location.name)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: didClearSelection) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel(Text("Close"))
          .accessibilityIdentifier("map.detail.close")
        }
      }
    }
    .accessibilityIdentifier("map.markerSheet.\(location.code)")
  }
}

#Preview {
  MarkerSheetView(
    location: CampusLocations.all[0],
    didClearSelection: {},
    didReturnToList: {}
  )
}
