import SwiftUI

struct LoginView: View {
  let errorMessage: String?
  let onLoginSuccess: (String) -> Void

  var body: some View {
    VStack(spacing: 0) {
      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundStyle(.red)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
          .padding(.vertical, 8)
          .background(.red.opacity(0.08))
      }

      LoginWebView(onLoginSuccess: onLoginSuccess)
    }
  }
}
