import Foundation

struct StudentIDStore {
  var appGroupIdentifier = AppSettings.appGroupSuiteName
  var fileName = "student-id.json"
  var fallbackDirectory: URL?

  func load() throws -> StudentIDRecord? {
    let url = try cacheURL()
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }

    let data = try Data(contentsOf: url)
    return try JSONDecoder.courseCache.decode(StudentIDRecord.self, from: data)
  }

  func save(_ record: StudentIDRecord) throws {
    let url = try cacheURL()
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )

    let data = try JSONEncoder.courseCache.encode(record)
    try data.write(to: url, options: [.atomic])
  }

  func clear() throws {
    let url = try cacheURL()
    guard FileManager.default.fileExists(atPath: url.path) else {
      return
    }

    try FileManager.default.removeItem(at: url)
  }

  func cacheURL() throws -> URL {
    if let sharedContainerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupIdentifier
    ) {
      return sharedContainerURL.appendingPathComponent(fileName)
    }

    guard let fallbackDirectory else {
      throw CourseCacheStoreError.sharedContainerUnavailable
    }

    return fallbackDirectory
      .appendingPathComponent(appGroupIdentifier, isDirectory: true)
      .appendingPathComponent(fileName)
  }
}

extension StudentIDStore {
  static var live: Self {
    #if DEBUG
      Self(fallbackDirectory: FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
      ).first)
    #else
      Self()
    #endif
  }
}
