import Foundation

struct StudentIDHTMLParser {
  func parse(data: Data) throws -> String {
    guard let html = String(data: data, encoding: .utf8) else {
      throw StudentIDClientError.invalidResponse
    }

    let normalizedHTML = html.replacingOccurrences(
      of: "\\s+",
      with: " ",
      options: .regularExpression
    )

    let pattern = #"學號：\s*([A-Za-z0-9]+)"#
    guard
      let regex = try? NSRegularExpression(pattern: pattern),
      let match = regex.firstMatch(
        in: normalizedHTML,
        range: NSRange(normalizedHTML.startIndex..., in: normalizedHTML)
      ),
      let studentIDRange = Range(match.range(at: 1), in: normalizedHTML)
    else {
      throw StudentIDClientError.studentIDNotFound
    }

    return String(normalizedHTML[studentIDRange])
  }
}
