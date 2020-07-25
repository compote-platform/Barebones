
extension Environ {

	public mutating func write(value: Any?, key: String) {
		self[key] = value
	}

	public func read<Generic>(key: EnvironKey) throws -> Generic {
		guard let value = self[key.rawValue] as? Generic else {
			throw APIError.typeMismatchOrMissingEnvironValueFor(key: key)
		}
		return value
	}
}

public extension Environ {

    func header<Generic>(_ header: Header, map: (String) -> Generic?) throws -> Generic? {
        let head: Head?

        if case .mandatory = header {
            head = try? read(key: .parsedHeaders)
        } else {
            head = try read(key: .parsedHeaders)
        }

        return try head?.read(header: header, map: map)
    }
}

public enum EnvironKey: String, Hashable, RawRepresentable {

	// http
	case method = "REQUEST_METHOD"
	case path = "PATH_INFO"

	// embassy
	case eventLoop = "embassy.event_loop"
	case httpConnection = "embassy.connection"

	// compote
	case parsedHeaders = "compote.http.headers"
	case parsedBody = "compote.http.parsedbody"

	case rawBody = "compote.http.raw.body"
}
