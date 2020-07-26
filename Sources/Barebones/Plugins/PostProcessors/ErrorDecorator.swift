
import PromiseKit

open class ErrorDecorator: Plugin {

	public enum Format {

		case json
		case text
	}

	public let format: Format

	public init(format: Format = .text) {
		self.format = format
	}

	public var work: WebWork {
		{ [unowned self] (worker: WebWorker) in
			guard
				worker.body.isEmpty && worker.data.isEmpty,
				worker.error.keys.count != 0,
				let error = [
					worker.error[.pending],
					worker.error[.preprocess],
					worker.error[.process],
					worker.error[.postprocess],
				].compactMap({ $0 }).first
				else { return .value(()) }
			worker.journal.log(.event("🎨 decorating error \(error)"))

			let apiError = APIError.wrapping(error: error)

			if case .json = self.format {
				worker.contentType = .json
				worker.body = apiError.json
			} else {
				worker.contentType = .txt
				worker.statusCode = apiError.code

				if let data = apiError.description.data(using: .utf8) {
					worker.data = data
				}
			}

			return .value(())
		}
	}
}
