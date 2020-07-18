
import Foundation
import Files
import HTMLString

public final class Upload: Request {

	public init(
		limit: Memory = .mb(10),
        baseURL: String,
		resolvedRoute: String,
		destination: Folder, //= Constants.Folder.static,
		timeout: TimeInterval = 5 * 60
	) {
		super.init(method: .post) { worker in
			let headers: Head = try worker.environ.read(key: .parsedHeaders)
			guard let fileExtension = headers["fileExtension"] else {
				throw APIError.specific(reason: "expected fileExtension header", code: 400)
			}
			let data: Data = try worker.environ.read(key: .rawBody)

			guard data.memorySize < limit else {
				throw APIError.specific(
					reason: "files bigger than \(limit.memoryDescription) are not allowed",
					code: 401
				)
			}

            let name = UUID().uuidString

			let file = try destination.createFileIfNeeded(withName: name + "." + fileExtension)
			try file.write(data)

			return .value([
				"response": [
					"path": "\(baseURL)/\(resolvedRoute)/\(file.name)".addingUnicodeEntities
				]
			])
		}

		expects(headers: ["fileExtension"])
		plugin(RawBodyReader(timeout: timeout))
	}
}
