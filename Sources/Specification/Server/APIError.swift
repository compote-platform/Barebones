
import HTMLString

public enum APIError: Swift.Error, CustomStringConvertible {

	case specific(reason: String, code: Int)

	public var code: Int {
		switch self {
			case .specific(_, let code): return code
		}
	}

	public var description: String {
		switch self {
			case .specific(let reason, _): return reason.addingUnicodeEntities
		}
	}

	public var json: Body { ["error": description] }

	public static func wrapping(error: Error) -> APIError {
		guard let apiError = error as? APIError else {
			return .underlyingError(error)
		}
		return apiError
	}

	public static func underlyingError(_ error: Error) -> APIError {
//		#if DEBUG
		return .specific(reason: "Internal error (ﾉ◕ヮ◕)ﾉ*:・ﾟ \(error)", code: 500)
//		#else
//		return .specific(reason: "Internal error (ﾉ◕ヮ◕)ﾉ*:・ﾟ", code: 500)
//		#endif
	}

	public static var internalError: APIError {
		.specific(reason: "Internal error (╯°□°）╯︵ ┻━┻ ", code: 500)
	}
	public static var notFound: APIError {
		.specific(reason: "Not found ¯\\_(ツ)_/¯ ", code: 404)
	}
	public static var invalidBody: APIError {
		.specific(reason: "Body type mismatch ( • )( • ) ԅ(≖‿≖ԅ)", code: 400)
	}
	public static var unauthorized: APIError {
		.specific(reason: "Unauthorized ಠ_ಠ", code: 401)
	}
	public static var noPostBody: APIError {
		.specific(reason: "Endpoint expects POST body as in JSON format ( • )( • ) ԅ(≖‿≖ԅ)", code: 400)
	}
	public static var badRequest: APIError {
		.specific(reason: "Bad request (ง •̀_•́)ง", code: 400)
	}
    public static func wrongMethod(expected: HTTPMethod, received: String) -> APIError {
        .specific(reason: "Wrong method while calling endpoint. Expected: \(expected.rawValue)/Received: \(received) (●__●)", code: 400)
	}
	public static func missing(header: String) -> APIError {
		.specific(reason: "Expected HTTP header: \(header)", code: 400)
	}
	public static func typeMismatchOrMissingEnvironValueFor(key: EnvironKey) -> APIError {
		.specific(reason: "Expected environ value for key: \(key)", code: 400)
	}
	public static var timeout: APIError {
		.specific(reason: "Request has timed out", code: 408)
	}
}
