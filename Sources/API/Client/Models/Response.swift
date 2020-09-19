
public struct Response<Contents: Codable>: Codable {

    public let result: Contents?
    public let error: String?
}
