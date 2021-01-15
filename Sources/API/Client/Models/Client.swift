//
//import Foundation
//import PromiseKit
//
//protocol Client {
//
//    init(endpoint: Endpoint) throws
//
//    func call() -> Promise<Data>
//}
//
//extension Endpoint {
//
//    /// returns the correct runner for
//    func client() throws -> Client {
//        #if os(iOS) || os(macOS)
//        return try native()
//        #elseif os(Linux) || os(macOS)
//        return try curl()
//        #else
//        fatalError("is current platform windows or what else ???")
//        #endif
//    }
//}
