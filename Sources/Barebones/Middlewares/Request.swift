
import PromiseKit
import Foundation

open class Request: Middleware {

    public init(
        method: HTTPMethod = .get,
        handler: @escaping (WebWorker) throws -> Promise<Void>,
        plugins: [PluginRuntimePosition: [Plugin]] = [
            .before: [
                HTTPMethodValidator(),
            ],
            .after: [
                ErrorDecorator(),
                Responder(),
            ],
        ]
    ) {
        plugins[.before]?.forEach {
            if let httpMethodValidator = $0 as? HTTPMethodValidator {
                httpMethodValidator.method = method
            }
        }

        super.init(handler: { (worker: WebWorker) -> Promise<Void> in
            try handler(worker)
        }, plugins: plugins)
    }

	public convenience init(
		method: HTTPMethod = .get,
		handler: @escaping (WebWorker) throws -> Promise<Body>,
        plugins: [PluginRuntimePosition: [Plugin]] = [
            .before: [
                HTTPMethodValidator(),
            ],
            .after: [
                JSONBodyDecorator(),
                ErrorDecorator(),
                Responder(),
            ],
        ]
	) {
        self.init(method: method, handler: { (worker: WebWorker) -> Promise<Void> in
            try handler(worker).map { body in
                worker.body = body
            }
        }, plugins: plugins)
	}

	public convenience init<GenericInput: BodyMaterializable>(
		method: HTTPMethod = .get,
		handler: @escaping (WebWorker, GenericInput) throws -> Promise<Body>,
        plugins: [PluginRuntimePosition: [Plugin]] = [
            .before: [
                HTTPMethodValidator(),
            ],
            .after: [
                JSONBodyDecorator(),
                ErrorDecorator(),
                Responder(),
            ],
        ]
	) {
        self.init(method: method, handler: { (worker: WebWorker) throws -> Promise<Body> in
			let input = try GenericInput.materialize(from: worker.environ)
			return try handler(worker, input)
        }, plugins: plugins)
        
        expectsJSONBody().plugin(Materializer<GenericInput>())
	}

	@discardableResult
    public func expects(headers: [Header]) -> Self {
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
