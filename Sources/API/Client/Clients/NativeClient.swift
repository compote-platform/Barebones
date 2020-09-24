
#if canImport(AsyncHTTPClient) && ( os(iOS) || os(macOS) )
import AsyncHTTPClient
import BarebonesSpecification
import Foundation
import PromiseKit

public struct NativeClient: Client {

    private static let client = HTTPClient(eventLoopGroupProvider: .createNew)

    let request: HTTPClient.Request

    public init(endpoint: Endpoint) throws {
        request = try endpoint.request()
    }

    public init(request: HTTPClient.Request) {
        self.request = request
    }

    public func call() -> Promise<Data> {
        Promise<Data> { resolver in
            Self.client.execute(request: request).whenComplete { result in
                switch result {
                    case .success(let response):
                        let bytes = response.body.flatMap { $0.getData(at: 0, length: $0.readableBytes) }

                        guard let data = bytes else {
                            resolver.reject(APIError.internalError)
                            return
                        }

                        resolver.fulfill(data)
                    case .failure(let error):
                        resolver.reject(error)
                }
            }
        }
    }
}

extension Endpoint {

    func native() throws -> Client {
        try NativeClient(endpoint: self)
    }
}

fileprivate extension Endpoint {

    func request() throws -> HTTPClient.Request {
        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        var headers = self.headers.map { key, value in (key, value) }

        headers.append(("Content-Type", "application/json"))

        return try .init(
            url: baseURL + path,
            method: .init(rawValue: method),
            headers: .init(headers),
            body: .data(data)
        )
    }
}
#endif
