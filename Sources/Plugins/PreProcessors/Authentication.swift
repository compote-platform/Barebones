
import BarebonesCore
import BarebonesSpecification
import PromiseKit

public protocol Credentials: Materializable {

    static var headers: [Header] { get }

	static func generate(from headers: Head) throws -> Promise<Self>
}

public class Authenticator<GenericCredentials: Credentials>: Materializer<GenericCredentials> {

	public override var work: WebWork {
		{ (worker: WebWorker) in
			return try HTTPHeadersReader(GenericCredentials.headers)
				.work(worker)
				.map { worker }
				.then(log(.event("🔑 authenticating " + "\(GenericCredentials.self)")))
				.map { worker }
				.then(super.work)
		}
	}
}

extension Credentials {

	public static func build(from environ: Environ) throws -> Promise<Self> {
		guard let headers: Head = try environ.read(key: .parsedHeaders) else {
			throw APIError.badRequest
		}
		return try Self.generate(from: headers)
	}
}
