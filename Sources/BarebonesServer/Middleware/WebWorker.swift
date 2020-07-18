
import Foundation
import PromiseKit

open class WebWorker {

	public indirect enum Stage: String, Hashable {

		// initialized
		case pending
		// performing work
		case preprocess
		case process
		case postprocess
		// sending response
		case response
		// resolution
		case done
		case failed
	}

	public var redirect: String? = nil
	public var stage: Stage = .pending
	
	public var statusCode: Int = 200
	public var contentType: ContentType = .none

	public var data = Data()
	public var body: Body = [:] {
		didSet {
			contentType = .json
		}
	}

	public var environ: Environ
	public var error: [Stage: Error] = [:]

	public let journal: Journal
	public let work: WebWork

	public init(
		journal: Journal,
		environ: Environ,
		work: @escaping WebWork
	) {
		self.journal = journal
		self.environ = environ
		self.work = work
	}
}

extension WebWorker {

	private func finish() {
		error.forEach { state, error in
			journal.log(.note("⚠️ failed with error: \(error), at state \(state)"))
		}

		if case .done = stage, error.keys.count == 0 {
			journal.log(.done("✅ finished response in " + "⏱ \(journal.stopwatch.runtime)"))
		} else if case .done = stage, error.keys.count > 0 {
			journal.log(.done("✅ finished response with errors in " + "⏱ \(journal.stopwatch.runtime)"))
		} else if case .failed = stage {
			journal.log(.done("❌ failed response with errors in " + "⏱ \(journal.stopwatch.runtime)"))
		} else {
			journal.log(.done("❌ failed response with errors in " + "⏱ \(journal.stopwatch.runtime)"))
		}

		journal.log(.separator)

		Journal.queue.sync {
			Journal.shared.extend(with: journal)
		}
		data = Data()
		body = [:]
		environ = [:]
	}

	public func execute() -> Promise<Void> {
		firstly { [unowned self] in try work(self) }
			.recover { [unowned self] error in self.error[self.stage] = error }
			.ensure { [unowned self] in
				if let _ = self.error[.response] {
					self.stage = .failed
				} else {
					self.stage = .done
				}
			}
			.ensure { [unowned self] in
				self.finish()
			}
	}
}
