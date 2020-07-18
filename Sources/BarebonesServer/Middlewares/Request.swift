
import PromiseKit
import Foundation

open class Request: Middleware {

	public init(
		method: HTTPMethod = .get,
		handler: @escaping (WebWorker) throws -> Promise<Body>
	) {
		super.init { (worker: WebWorker) throws -> Promise<Void> in
			try handler(worker).map { body in
				worker.body = body
			}
		}

		plugin(HTTPMethodValidator(method: method))
		plugin(ErrorDecorator(), when: .after)
	}

	public convenience init<GenericInput: BodyMaterializable>(
		method: HTTPMethod = .get,
		handler: @escaping (WebWorker, GenericInput) throws -> Promise<Body>
	) {
		self.init(method: method) { (worker: WebWorker) throws -> Promise<Body> in
			let input = try GenericInput.materialize(from: worker.environ)
			return try handler(worker, input)
		}
		
		expectsJSONBody()
		plugin(Materializer<GenericInput>())
	}

	@discardableResult
	public func expects(headers: [String]) -> Self {
		plugin(HTTPHeadersReader(headers))
	}

	@discardableResult
	public func expectsJSONBody(timeout: TimeInterval = 3) -> Self {
		expectsBody().plugin(JSONBodyParser(timeout: timeout))
	}

	@discardableResult
	public func expectsBody(timeout: TimeInterval = 3) -> Self {
		plugin(RawBodyReader(timeout: timeout))
	}
}
