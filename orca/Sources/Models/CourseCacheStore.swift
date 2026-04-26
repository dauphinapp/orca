import Foundation

struct CourseCacheStore {
  var appGroupIdentifier = AppSettings.appGroupSuiteName
  var fileName = "courses.json"
  var fallbackDirectory: URL?

  func load() throws -> CourseCache? {
    let url = try cacheURL()
    guard FileManager.default.fileExists(atPath: url.path) else {
      return nil
    }

    let data = try Data(contentsOf: url)
    return try JSONDecoder.courseCache.decode(CourseCache.self, from: data)
  }

  func save(_ cache: CourseCache) throws {
    let url = try cacheURL()
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )

    let data = try JSONEncoder.courseCache.encode(cache)
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

enum CourseCacheStoreError: LocalizedError {
  case sharedContainerUnavailable

  var errorDescription: String? {
    switch self {
    case .sharedContainerUnavailable:
      "Shared course cache container is unavailable."
    }
  }
}

extension CourseCacheStore {
  static var live: Self { Self() }
}

extension JSONEncoder {
  static var courseCache: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }
}

extension JSONDecoder {
  static var courseCache: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }
}
