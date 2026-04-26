@preconcurrency import MapKit
import SwiftUI

struct LandmarkView: View {
  let coordinate: CLLocationCoordinate2D

  @Environment(\.openURL) private var openURL
  @State private var lookAroundScene: MKLookAroundScene?

  var body: some View {
    VStack(spacing: 16) {
      HStack(spacing: 12) {
        mapPreview
        lookAroundPreview
      }

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
      .accessibilityIdentifier("map.action.directions")
    }
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
    .aspectRatio(1, contentMode: .fit)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .accessibilityLabel(Text("Campus Map"))
  }

  private var lookAroundPreview: some View {
    LookAroundPreview(scene: $lookAroundScene, allowsNavigation: true, showsRoadLabels: true)
      .aspectRatio(1, contentMode: .fit)
      .clipShape(.rect(cornerRadius: 12))
      .task {
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        lookAroundScene = try? await request.scene
      }
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
