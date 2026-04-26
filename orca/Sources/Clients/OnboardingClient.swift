import ComposableArchitecture
import Foundation

struct OnboardingClient {
  var hasSeenOnboarding: @Sendable () async -> Bool
  var setHasSeenOnboarding: @Sendable (Bool) async -> Void
}

extension OnboardingClient: DependencyKey {
  static let liveValue = Self(
    hasSeenOnboarding: {
      UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
    },
    setHasSeenOnboarding: { value in
      UserDefaults.standard.set(value, forKey: hasSeenOnboardingKey)
    }
  )

  static let testValue = Self(
    hasSeenOnboarding: { false },
    setHasSeenOnboarding: { _ in }
  )
}

extension DependencyValues {
  var onboardingClient: OnboardingClient {
    get { self[OnboardingClient.self] }
    set { self[OnboardingClient.self] = newValue }
  }
}

private let hasSeenOnboardingKey = "hasSeenOnboarding"
