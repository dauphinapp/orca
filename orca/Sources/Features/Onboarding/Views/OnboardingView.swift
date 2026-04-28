import SwiftUI
import MapKit

struct OnboardingView: View {
    let onGetStarted: () -> Void

    private let center = CLLocationCoordinate2D(
        latitude: 25.17553,
        longitude: 121.45063
    )

    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(
                latitude: 25.17553,
                longitude: 121.45063
            ),
            distance: 2600,
            heading: 80,
            pitch: 0
        )
    )

    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .mapControlVisibility(.hidden)
                .allowsHitTesting(false)
                .ignoresSafeArea()
                .task {
                    try? await Task.sleep(for: .milliseconds(300))

                    withAnimation(.easeInOut(duration: 2.4)) {
                        cameraPosition = .camera(
                            MapCamera(
                                centerCoordinate: center,
                                distance: 1600,
                                heading: 100,
                                pitch: 35
                            )
                        )
                    }
                }

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Dauphin")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Sign in to continue.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    onGetStarted()
                } label: {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(24)
        }
    }
}
#Preview {
  OnboardingView {}
}
