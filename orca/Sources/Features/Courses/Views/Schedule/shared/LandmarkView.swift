@preconcurrency import MapKit
import SwiftUI

struct LandmarkView: View {
  let coordinate: CLLocationCoordinate2D

  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(spacing: 14) {
      mapPreview

      Button {
        openDirections()
      } label: {
        Label(
          "Open in Maps",
          systemImage: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath.fill"
        )
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .accessibilityIdentifier("map.action.directions")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(18)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
  }

  private var mapPreview: some View {
    Map(
      initialPosition: .region(
        MKCoordinateRegion(
          center: coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
      )
    ) {
      Annotation("", coordinate: coordinate) {
        Image(systemName: "mappin")
          .foregroundStyle(.red)
          .accessibilityHidden(true)
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: 200)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    .accessibilityLabel(Text("Campus Map"))
  }

  private func openDirections() {
    let googleURLString =
      "comgooglemaps://?daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving"

    if let googleURL = URL(string: googleURLString) {
      openURL(googleURL) { accepted in
        if !accepted {
          openAppleDirections()
        }
      }
    } else {
      openAppleDirections()
    }
  }

  private func openAppleDirections() {
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.openInMaps(launchOptions: [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
  }
}

#Preview {
  LandmarkView(coordinate: CampusLocations.coordinate(forRoom: "E 414"))
    .padding()
}
