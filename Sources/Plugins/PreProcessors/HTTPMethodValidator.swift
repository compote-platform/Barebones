
import BarebonesCore
import BarebonesSpecification

public struct HTTPMethodValidator: Plugin {

    public var method: HTTPMethod

    public init(method: HTTPMethod = .get) {
        self.method = method
    }

	public var work: WebWork {
		{ _ in
//			let method: String = try $0.environ.read(key: .method)
//            guard method == self.method.rawValue else {
//                throw APIError.wrongMethod(expected: self.method, received: method)
//            }
			return .value(())
		}
	}
}
