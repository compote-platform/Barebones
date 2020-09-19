
public protocol HTTPEncodable: Codable {

    func headers() throws -> [String: String]
    func body() throws -> [String: Any]
}
