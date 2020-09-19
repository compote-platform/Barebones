
import Journal
import BarebonesSpecification
import BarebonesCore
import PromiseKit

public struct HTTPHeadersReader: Plugin {

	public let headers: [Header]

	public init(_ expectedHeaders: [Header]) {
		headers = expectedHeaders
	}

	public var work: WebWork {
		{ (worker: WebWorker) in
            worker.journal.log(.todo("📖 reading headers [\(self.headers.map(\.rawValue).joined(separator: ", "))]"))

			let justReadHeaders: [(String, String)] = try self.headers.compactMap { header in
                let swsgiHeaderKey = "HTTP_" + header.rawValue
					.uppercased()
					.replacingOccurrences(of: "-", with: "_")

                if let value = worker.environ[swsgiHeaderKey] as? String {
                    return (header.rawValue, value)
                } else {
                    if case .mandatory = header {
                        throw APIError.missing(header: header.rawValue)
                    }

                    return .none
                }
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

            worker.journal.log(.done("📖 reading headers [\(self.headers.map(\.rawValue).joined(separator: ", "))]"))

			return .value(())
		}
	}
}
