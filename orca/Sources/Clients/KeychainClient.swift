import Foundation
import Security

struct KeychainClient {
  enum Account: String {
    case sessionCookie = "session_cookie"
  }

  var loadString: @Sendable (Account) -> String?
  var saveString: @Sendable (String, Account) throws -> Void
  var delete: @Sendable (Account) throws -> Void

  static let live = Self(
    loadString: { account in
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account.rawValue,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true,
      ]

      var result: AnyObject?
      let status = SecItemCopyMatching(query as CFDictionary, &result)

      if status == errSecMissingEntitlement {
        #if DEBUG
          return fallbackDefaults.string(forKey: fallbackKey(for: account))
        #else
          return nil
        #endif
      }

      guard status == errSecSuccess, let data = result as? Data else {
        return nil
      }

      return String(data: data, encoding: .utf8)
    },
    saveString: { value, account in
      let data = Data(value.utf8)
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account.rawValue,
      ]
      let attributes: [String: Any] = [
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
      ]

      let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
      if updateStatus == errSecSuccess {
        return
      }

      if updateStatus == errSecMissingEntitlement {
        #if DEBUG
          fallbackDefaults.set(value, forKey: fallbackKey(for: account))
          return
        #else
          throw KeychainError.unhandledStatus(updateStatus)
        #endif
      }

      guard updateStatus == errSecItemNotFound else {
        throw KeychainError.unhandledStatus(updateStatus)
      }

      var addQuery = query
      addQuery[kSecValueData as String] = data
      addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

      let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
      if addStatus == errSecMissingEntitlement {
        #if DEBUG
          fallbackDefaults.set(value, forKey: fallbackKey(for: account))
          return
        #else
          throw KeychainError.unhandledStatus(addStatus)
        #endif
      }

      guard addStatus == errSecSuccess else {
        throw KeychainError.unhandledStatus(addStatus)
      }
    },
    delete: { account in
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account.rawValue,
      ]

      let status = SecItemDelete(query as CFDictionary)
      if status == errSecMissingEntitlement {
        #if DEBUG
          fallbackDefaults.removeObject(forKey: fallbackKey(for: account))
          return
        #else
          throw KeychainError.unhandledStatus(status)
        #endif
      }

      guard status == errSecSuccess || status == errSecItemNotFound else {
        throw KeychainError.unhandledStatus(status)
      }

      fallbackDefaults.removeObject(forKey: fallbackKey(for: account))
    }
  )
}

private var service: String {
  Bundle.main.bundleIdentifier ?? "cantpr09ram.dauphin"
}
nonisolated(unsafe) private let fallbackDefaults = UserDefaults.standard

private func fallbackKey(for account: KeychainClient.Account) -> String {
  "\(service).\(account.rawValue)"
}

enum KeychainError: LocalizedError, Equatable {
  case unhandledStatus(OSStatus)

  var errorDescription: String? {
    switch self {
    case .unhandledStatus(let status):
      "Keychain operation failed with status \(status)."
    }
  }
}
