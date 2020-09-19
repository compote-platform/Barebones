
import Foundation

extension Encodable where Self: Decodable {

    public func asBody() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let json = try JSONSerialization.jsonObject(with: data)

        guard let body = json as? [String: Any] else {
            throw APIError.internalError
        }

        return body
    }
}
