
import Foundation
import Ambassador
import Embassy
import PromiseKit

open class Middleware {

	public var timeout: TimeInterval = 15
	public var plugins = [PluginRuntimePosition: [Plugin]]()
	public var handler: WebWork

    public init(
        handler: @escaping WebWork = { _ in return .value(()) },
        plugins: [PluginRuntimePosition: [Plugin]] = [
            .after: [
                Responder(),
            ],
        ]
    ) {
		self.handler = handler
        plugins[.before]?.forEach { self.plugin($0, when: .before) }
        plugins[.after]?.forEach { self.plugin($0, when: .after) }
	}

	@discardableResult
	open func timeout(at delay: TimeInterval) -> Self {
		timeout = delay
		return self
	}

	open var preProcess: WebWork {
		guard let preProcess = plugins[.before], !preProcess.isEmpty else {
			return [].process
		}

		return { (worker: WebWorker) in
			guard case .preprocess = worker.stage else {
				worker.journal
					.log(.event("📦 pre processing with plugins" + "skipped"))
				return .value(())
			}
			return try [
				log(.todo("📦 pre processing with plugins")),
				preProcess.map(\.work).process,
				log(.done("📦 pre processing with plugins")),
				log(.event("🎁 done pre processing with plugins")),
			].process(worker)
		}
	}

	open var process: WebWork {
		{ (worker: WebWorker) in
			guard case .process = worker.stage else {
				worker.journal
					.log(.event("⚙️ processing" + "skipped"))
				return .value(())
			}
			return try [
				log(.todo("⚙️ processing")),
				self.handler,
				log(.done("⚙️ processing")),
				log(.event("🛠 done processing")),
			].process(worker)
		}
	}

	open var postProcess: WebWork {
		guard let postProcess = self.plugins[.after], !postProcess.isEmpty else {
			return [].process
		}

		return { (worker: WebWorker) in
			guard case .postprocess = worker.stage else {
				worker.journal
					.log(.event("🔧 post processing with plugins" + "skipped"))
				return .value(())
			}
			return try [
				log(.todo("🔧 post processing with plugins")),
				postProcess.map(\.work).process,
				log(.done("🔧 post processing with plugins")),
				log(.event("⚙️ done post processing with plugins")),
			].process(worker)
		}
	}

	open var work: WebWork {
		{ [unowned self] worker in
			let promise = firstly { Promise.value(worker) }
				.ensure {
					let path: String = try! worker.environ.read(key: .path)
					worker.journal.log(.event("💬 serving path \(path)"))
				}
				.ensure {
					guard case .pending = worker.stage else { return }
					worker.stage = .preprocess
				}
				.then(self.preProcess)
				.recover { catchedError in
					worker.error[worker.stage] = catchedError
				}
				.ensure {
					guard case .preprocess = worker.stage else { return }
					worker.stage = .process
				}
				.map { worker }
				.then(self.process)
				.recover { catchedError in
					worker.error[worker.stage] = catchedError
				}
				.ensure {
					guard case .process = worker.stage else { return }
					worker.stage = .postprocess
				}
				.map { worker }
				.then(self.postProcess)
				.recover { catchedError in
					worker.error[worker.stage] = catchedError
				}
				.ensure {
					worker.stage = .response
				}
			let timeout = after(seconds: self.timeout).map { _ -> Void in
				if worker.stage == .preprocess
					|| worker.stage == .postprocess
					|| worker.stage == .process
					|| worker.stage == .response
				{
					worker.journal.log(.event("⏱ timed out request on stage \(worker.stage)"))
				}
				return ()
			}
			return race(when(resolved: [promise]).asVoid(), timeout)
		}
	}
}

extension Middleware: PluginExtendable {

	@discardableResult
	public func plugin(_ plugin: Plugin, when stage: PluginRuntimePosition = .before) -> Self {
		var pluginsByStage = plugins[stage] ?? []
		pluginsByStage.append(plugin)
		plugins[stage] = pluginsByStage
		return self
	}
}

extension Middleware: WebApp {

	open func app(
		_ environ: [String : Any],
		startResponse: @escaping ((String, [(String, String)]) -> Void),
		sendBody: @escaping ((Data) -> Void)
	) {
        plugins[.after]?.compactMap { $0 as? Responder }.forEach {
            $0.startResponse = startResponse
            $0.sendBody = sendBody
        }

		let worker: WebWorker! = WebWorker(
			journal: Journal(),
			environ: environ,
			work: work
		)

		worker.execute().ensure {
			if let connection: HTTPConnection = try? worker.environ.read(key: .httpConnection) {
				connection.close()
			}

		}.cauterize()
	}
}
