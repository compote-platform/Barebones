
import Dispatch
import Foundation
import PromiseKit

open class Router: Middleware {

	public private(set) var routes = [String: Middleware]()
	public let semaphore = DispatchSemaphore(value: 1)

	public init() {
		super.init()
		handler = { [unowned self] worker in
			let path: String = try worker.environ.read(key: .path)
			worker.journal.log(.todo("🔗 routing: \(path)"))

			guard let handler = self.route(to: path, on: worker) else { throw APIError.notFound }
			worker.stage = .pending

			worker.journal.log(.done("🔗 routing: \(path)"))
			return try [
				{ $0.stage = .preprocess; return .value(()) },
				handler.work,
				{ $0.stage = .process; return .value(()) }
			].process(worker)
		}
        plugins = [
            .after: [
                ErrorDecorator(),
                Responder(),
            ],
        ]
	}

	open func route(to path: String, on worker: WebWorker) -> Middleware? {
		var middleware: Middleware? = self["/"]
		let parts = path.components(separatedBy: "/").filter { !$0.isEmpty }

		guard
			let head = parts.first,
			routes.keys.contains(head)
			else { return middleware }

		middleware = self[head]

		if middleware is Router {
			let subpath = "/" + parts.dropFirst().joined(separator: "/")
			worker.environ.write(value: subpath, key: EnvironKey.path.rawValue)
		}

		return middleware
	}

	open func route(_ path: String, _ middleware: Middleware) {
		self[path] = middleware
	}

	open subscript(path: String) -> Middleware? {
        get {
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            defer {
                semaphore.signal()
            }
            return routes[path]
        }

        set {
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            defer {
                semaphore.signal()
            }
            routes[path] = newValue!
        }
    }
}
