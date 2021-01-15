//
//import Signature
//import BarebonesSpecification
//
//extension EndpointSpecification {
//
//    static func bareEndpoint(_ baseURL: String) -> Endpoint {
//        Endpoint(baseURL: baseURL, path: Self.path, method: Self.method.rawValue)
//    }
//
//    public static var path: String {
//        Signature
//            .dynamic(Self.self).rawValue
//            .components(separatedBy: ".").dropFirst()
//            .map { $0.lowercased() }
//            .joined(separator: "/")
//    }
//}
//
//extension EndpointSpecification where Input: HTTPEncodable {
//
//    public static func endpoint(_ input: Input, baseURL: String) throws -> Endpoint {
//        Self.bareEndpoint(baseURL)
//            .with(headers: try input.headers())
//            .with(parameters: try input.body())
//    }
//}
//
//import PromiseKit
//import Foundation
//
//extension EndpointSpecification where Input: HTTPEncodable {
//
//    public static func call(_ input: Input, baseURL: String) -> Promise<Response<Output>> {
//        firstly {
//            .value(input)
//        }
//        .then { input  -> Promise<Client> in
//            .value(try Self.endpoint(input, baseURL: baseURL).client())
//        }
//        .then { $0.call() }
//        .map { data in
//            do {
//                let output = try JSONDecoder().decode(Output.self, from: data)
//                return Response<Output>(result: output, error: .none)
//            } catch {
//                return try JSONDecoder().decode(Response<Output>.self, from: data)
//            }
//        }
//        .recover { error -> Guarantee<Response<Output>> in
//            .value(Response<Output>(result: .none, error: "\(error)"))
//        }
//    }
//}
//
//#if canImport(Combine) && ( os(iOS) || os(macOS) )
//import Combine
//import BarebonesSpecification
//
//extension EndpointSpecification where Input: HTTPEncodable {
//
//    /// Provides this publisher https://developer.apple.com/documentation/combine/future
//    public static func publisher(_ input: Input, baseURL: String) -> Future<Output, Error> {
//        Future { promise in
//            call(input, baseURL: baseURL).map { response in
//                if let result = response.result {
//                    promise(.success(result))
//                } else if let error = response.error {
//                    promise(.failure(APIError.specific(reason: error, code: 500)))
//                } else {
//                    promise(.failure(APIError.internalError))
//                }
//            }.cauterize()
//        }
//    }
//}
//#endif
