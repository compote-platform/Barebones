//
//public struct Endpoint {
//
//    public var baseURL: String
//    public var path: String
//    public var method: String
//    public var parameters: [String: Any] = [:]
//    public var headers: [String: String] = [:]
//
//    public init(
//        baseURL: String,
//        path: String,
//        method: String,
//        parameters: [String: Any] = [:],
//        headers: [String: String] = [:]
//    ) {
//        self.baseURL = baseURL
//        self.path = path
//        self.method = method
//        self.parameters = parameters
//        self.headers = headers
//    }
//}
//
//extension Endpoint {
//
//    func with(parameters: [String: Any]) -> Endpoint {
//        var endpoint = self
//        endpoint.parameters = parameters
//        return endpoint
//    }
//
//    func with(headers: [String: String]) -> Endpoint {
//        var endpoint = self
//        endpoint.headers = headers
//        return endpoint
//    }
//}
//
//import Curl
//
//public extension Endpoint {
//
//    func curl() throws -> Curl {
//        try Curl(
//            url: baseURL + path,
//            method: method,
//            parameters: parameters,
//            headers: headers
//        )
//    }
//}
