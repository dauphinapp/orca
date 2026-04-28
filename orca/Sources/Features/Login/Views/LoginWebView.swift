import SwiftUI
import WebKit

struct LoginWebView: UIViewRepresentable {
  let onLoginSuccess: (String) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(onLoginSuccess: onLoginSuccess)
  }

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .default()

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    configuration.websiteDataStore.httpCookieStore.add(context.coordinator)

    var request = URLRequest(url: loginURL)
    request.cachePolicy = .reloadIgnoringLocalCacheData
    webView.load(request)

    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {}

  final class Coordinator: NSObject, WKHTTPCookieStoreObserver, WKNavigationDelegate {
    private let onLoginSuccess: (String) -> Void
    private var didSendCookie = false

    init(onLoginSuccess: @escaping (String) -> Void) {
      self.onLoginSuccess = onLoginSuccess
    }

    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
      readSessionCookie(from: cookieStore)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
      readSessionCookie(from: webView.configuration.websiteDataStore.httpCookieStore)
    }

    private func readSessionCookie(from cookieStore: WKHTTPCookieStore) {
      cookieStore.getAllCookies { [weak self] cookies in
        guard let self, !didSendCookie else {
          return
        }

        guard let sessionCookie = cookies.first(where: { $0.name == sessionCookieName }) else {
          return
        }

        didSendCookie = true
        DispatchQueue.main.async {
          self.onLoginSuccess(sessionCookie.value)
        }
      }
    }
  }
}

private let loginURL = URL(string: "https://ilifeapp.az.tku.edu.tw")!
private let sessionCookieName = ".AspNetCore.Cookies"
