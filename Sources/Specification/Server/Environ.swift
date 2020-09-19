
public typealias Environ = [String: Any]

public enum EnvironKey: String, Hashable, RawRepresentable {


	case method = "REQUEST_METHOD"
	case path = "PATH_INFO"

	case eventLoop = "embassy.event_loop"
	case httpConnection = "embassy.connection"

	case parsedHeaders = "barebones.http.headers"
	case parsedBody = "barebones.http.parsedbody"

	case rawBody = "barebones.http.raw.body"
}
