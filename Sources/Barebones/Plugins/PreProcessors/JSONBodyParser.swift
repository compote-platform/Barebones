
import Foundation

public struct JSONBodyParser: Plugin {

	public var timeout: TimeInterval

	public init(timeout: TimeInterval) {
		self.timeout = timeout
	}

	public var work: WebWork {
		{ (worker: WebWorker) in
			let raw: Data = try worker.environ.read(key: .rawBody)
			let json = try JSONSerialization.jsonObject(with: raw)

			guard let body = json as? Body else {
				throw APIError.invalidBody
			}

			worker.environ.write(value: body, key: EnvironKey.parsedBody.rawValue)
			return .value(())
		}
	}
}
