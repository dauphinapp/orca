import SwiftUI

struct OnboardingView: View {
  let onGetStarted: () -> Void

  var body: some View {
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

#Preview {
  OnboardingView {}
}
