
#if os(macOS) || os(Linux)
import Foundation
import Curl
import PromiseKit

extension Curl: Client {

    public init(endpoint: Endpoint) throws {
        self = try endpoint.curl()
    }

    public func call() -> Promise<Data> { async() }
}

#endif
