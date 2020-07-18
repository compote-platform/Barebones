
import PromiseKit

@inline(__always) internal func log(_ entry: Journal.Entry) -> WebWork {
	{ (worker: WebWorker) -> Promise<Void> in
		worker.journal.log(entry)
		return .value(())
	}
}

public typealias WebWork = (WebWorker) throws -> Promise<Void>

extension Array where Element == WebWork {

	public var process: WebWork {
		{ worker in
			guard let head = self.first else { return .value(()) }
			let tail = Array(self.dropFirst())

			return Promise
				.value(worker)
				.then(head)
				.map { worker }
				.then(tail.process)
		}
	}
}

