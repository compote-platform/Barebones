
public struct HTTPMethodValidator: Plugin {

	public let method: HTTPMethod

	public var work: WebWork {
		{
			let method: String = try $0.environ.read(key: .method)
			guard method == self.method.rawValue else { throw APIError.wrongMethod }
			return .value(())
		}
	}
}
