
import BarebonesSpecification
import Foundation
import PromiseKit
import Embassy
import Ambassador

public struct RawBodyReader: Plugin {

	public var timeout: TimeInterval

	public init(timeout: TimeInterval) {
		self.timeout = timeout
	}

	public var work: WebWork {
		{ (worker: WebWorker) in
			guard let input = worker.environ["swsgi.input"] as? SWSGIInput else {
				throw APIError.noPostBody
			}
			let loop: EventLoop = try worker.environ.read(key: .eventLoop)
			let promise = Promise<Data>.pending()

			loop.call(withDelay: self.timeout) {
				worker.journal.log(.event("⏱ timed out reading body"))
				promise.resolver.reject(APIError.timeout)
			}
			loop.call {
				worker.journal.log(.todo("📚 reading body"))
				DataReader.read(input) { data in
					worker.journal.log(.done("📚 reading body"))
					promise.resolver.fulfill(data)
				}
			}

			return promise.promise.map { (body: Data) -> Void  in
				worker.environ.write(value: body, key: EnvironKey.rawBody.rawValue)
				return ()
			}
		}
	}
}

