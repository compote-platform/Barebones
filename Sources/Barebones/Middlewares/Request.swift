
import PromiseKit
import Foundation

open class Request: Middleware {

    public init(
        method: HTTPMethod = .get,
        timeout: TimeInterval = 15,
        handler: @escaping WebWork = { _ in return .value(()) },
        plugins: [PluginRuntimePosition: [Plugin]] = [
            .after: [
                ErrorDecorator(),
                Responder(),
            ],
        ]
    ) {
        super.init(
            timeout: timeout,
            handler: handler,
            plugins: plugins
        )

        plugin(HTTPMethodValidator(method: method))
    }

	public convenience init(
		method: HTTPMethod = .get,
        timeout: TimeInterval = 15,
		handler: @escaping (WebWorker) throws -> Promise<Body>,
        plugins: [PluginRuntimePosition: [Plugin]] = [
            .after: [
                ErrorDecorator(),
                JSONBodyDecorator(),
                Responder(),
            ],
        ]
	) {
        self.init(
            method: method,
            timeout: timeout,
            handler: { (worker: WebWorker) -> Promise<Void> in
                try handler(worker).map { body in
                    worker.body = body
                }
            },
            plugins: plugins
        )
	}

	public convenience init<GenericInput: BodyMaterializable>(
		method: HTTPMethod = .get,
        timeout: TimeInterval = 15,
		handler: @escaping (WebWorker, GenericInput) throws -> Promise<Body>,
        plugins: [PluginRuntimePosition: [Plugin]] = [
            .after: [
                ErrorDecorator(),
                JSONBodyDecorator(),
                Responder(),
            ],
        ]
	) {
        self.init(
            method: method,
            timeout: timeout,
            handler: { (worker: WebWorker) throws -> Promise<Body> in
                let input = try GenericInput.materialize(from: worker.environ)
                return try handler(worker, input)
            },
            plugins: plugins
        )
        
        expectsJSONBody()
        plugin(Materializer<GenericInput>())
	}

    public convenience init<GenericInput: Materializable>(
        method: HTTPMethod = .get,
        timeout: TimeInterval = 15,
        handler: @escaping (WebWorker, GenericInput) throws -> Promise<Body>,
        plugins: [PluginRuntimePosition: [Plugin]] = [
        .after: [
            ErrorDecorator(),
            JSONBodyDecorator(),
            Responder(),
        ],
        ]
    ) {
        self.init(
            method: method,
            timeout: timeout,
            handler: { (worker: WebWorker) throws -> Promise<Body> in
                let input = try GenericInput.materialize(from: worker.environ)
                return try handler(worker, input)
        },
            plugins: plugins
        )

        plugin(Materializer<GenericInput>())
    }
}
