
import BarebonesCore
import BarebonesSpecification
import PromiseKit

public protocol BodyMaterializable: Materializable {

	static func generate(from environ: Environ, body: [String: Any]) throws -> Promise<Self>
}

extension BodyMaterializable {

	public static func build(from environ: Environ) throws -> Promise<Self> {
		guard let body: Body = try environ.read(key: .parsedBody) else {
			throw APIError.badRequest
		}
        return try generate(from: environ, body: body)
	}
}
