
public final class HTTPMethodValidator: Plugin {

    public var method: HTTPMethod = .get

    public init() {}

	public var work: WebWork {
		{
			let method: String = try $0.environ.read(key: .method)
            guard method == self.method.rawValue else {
                throw APIError.wrongMethod(expected: self.method, received: method)
            }
			return .value(())
		}
	}
}
