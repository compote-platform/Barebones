
import PromiseKit

public protocol Materializable {

	static var environKey: String { get }

	static func build(from environ: Environ) throws -> Promise<Self>
}

extension Materializable {

	public static func materialize(from environ: Environ) throws -> Self {
		guard let substance = environ[Self.environKey] as? Self else {
			throw APIError.badRequest
		}
		return substance
	}
}

open class Materializer<Substance: Materializable>: Plugin {
	
	public init() {}

	public var work: WebWork {
		{ (worker: WebWorker) in
			worker.journal.log(.event("🧬 materializing \(Substance.self)"))
			return try Substance.build(from: worker.environ).map { substance in
				worker.environ.write(value: substance, key: Substance.environKey)
			}
		}
	}
}
