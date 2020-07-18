
import PromiseKit

public struct HTTPHeadersReader: Plugin {

	public let headers: [String]

	public init(_ expectedHeaders: [String]) {
		headers = expectedHeaders
	}

	public var work: WebWork {
		{ (worker: WebWorker) in
			worker.journal.log(.todo("📖 reading headers [\(self.headers.joined(separator: ", "))]"))

			let justReadHeaders: [(String, String)] = try self.headers.map { key in
				let swsgiHeaderKey = "HTTP_" + key
					.uppercased()
					.replacingOccurrences(of: "-", with: "_")
				
				guard let header = worker.environ[swsgiHeaderKey] as? String else {
					throw APIError.missing(header: key)
				}
				return (key, header)
			}

			let headers = Head(uniqueKeysWithValues: justReadHeaders)

			if let parsedHeaders = worker.environ[EnvironKey.parsedHeaders.rawValue] as? Head {
				let merged = parsedHeaders.merging(headers) { (_, new) in return new }
				worker.environ.write(
					value: merged,
					key: EnvironKey.parsedHeaders.rawValue)
			} else {
				worker.environ.write(
					value: headers,
					key: EnvironKey.parsedHeaders.rawValue
				)
			}

			worker.journal.log(.done("📖 reading headers [\(self.headers.joined(separator: ", "))]"))

			return .value(())
		}
	}
}
