
import Foundation
import PromiseKit
import HTMLString
import Files

open class StaticFolder: Middleware {

	public init(
		route: String,
		folder staticFolderPath: String,
		allowedContent: [ContentType] = ContentType.allowedStatic
	) {
		super.init()
		let cachier = Cachier()

		plugin(ErrorDecorator(format: .text), when: .after)
		plugin(cachier, when: .after)
		plugin(cachier, when: .before)

		handler = { (worker: WebWorker) in
			let folder = try Folder.root.createSubfolderIfNeeded(at: staticFolderPath)
			let requestedPath: String = try worker.environ.read(key: .path)

			guard !requestedPath.contains("..") else { throw APIError.unauthorized }
			guard let unescaped = requestedPath.removingPercentEncoding else { throw APIError.badRequest }

			let path = unescaped.components(separatedBy: route).dropFirst().joined(separator: route)

			worker.contentType = .txt
			worker.journal.log(.event("🔖 serving static path \(path)"))

			if folder.containsFile(at: path) {
				let file = try folder.file(at: path)

				if
					let fileExtension = file.extension,
					let contentType = StaticFolder.contentTypesByFileExtension[fileExtension]
				{
					guard allowedContent.contains(contentType) else {
						throw APIError.unauthorized
					}
					worker.contentType = contentType
				}

				worker.data = try file.read()
				worker.journal.log(.event("💾 serving static file \(file.path), size: \(worker.data.memoryDescription), as \(worker.contentType)"))
			} else if folder.containsSubfolder(at: path) {
				let directory = try folder.subfolder(at: path)

				if directory.containsFile(named: "index.html") {
					let file = try directory.file(named: "index.html")
					if
						let fileExtension = file.extension,
						let contentType = StaticFolder.contentTypesByFileExtension[fileExtension]
					{
						guard allowedContent.contains(contentType) else {
							throw APIError.unauthorized
						}
						worker.contentType = contentType
					}

					worker.data = try file.read()
					worker.journal.log(.event("💾 serving static file \(file.path), size: \(worker.data.memoryDescription), as \(worker.contentType)"))
				} else {
					worker.journal.log(.event("🗄 serving static folder \(directory.path)"))
					worker.body = [
						"response": [
							"folders": directory.subfolders.map {
								[
									"name": $0.name,
									"path": $0.path.addingUnicodeEntities,
//									"createdAt": ZonedDateTime($0.creationDate ?? Date()).toDate().iso8601,
								]
							},
							"files": directory.files.map {
								[
									"name": $0.name,
									"path": $0.path,
//									"createdAt": ZonedDateTime($0.creationDate ?? Date()).toDate().iso8601,
								]
							}
						]
					]
				}
			} else {
				throw APIError.notFound
			}
			return .value(())
		}
	}

	private static let contentTypesByFileExtension: [String: ContentType] = [
		"aac": .aac,
		"abw": .abw,
		"arc": .arc,
		"avi": .avi,
		"azw": .azw,
		"bin": .bin,
		"bmp": .bmp,
		"bz": .bz,
		"bz2": .bz2,
		"csh": .csh,
		"css": .css,
		"csv": .csv,
		"doc": .doc,
		"docx": .docx,
		"eot": .eot,
		"epub": .epub,
		"gz": .gz,
		"gif": .gif,
		"html": .html,
		"ico": .ico,
		"ics": .ics,
		"jar": .jar,
		"jpg": .jpg,
		"js": .js,
		"json": .json,
		"jsonld": .jsonld,
		"midi": .midi,
		"mp3": .mp3,
		"mpeg": .mpeg,
		"mpkg": .mpkg,
		"odp": .odp,
		"ods": .ods,
		"odt": .odt,
		"oga": .oga,
		"ogv": .ogv,
		"ogx": .ogx,
		"opus": .opus,
		"otf": .otf,
		"png": .png,
		"pdf": .pdf,
		"php": .php,
		"ppt": .ppt,
		"pptx": .pptx,
		"rar": .rar,
		"rtf": .rtf,
		"sh": .sh,
		"svg": .svg,
		"swf": .swf,
		"tar": .tar,
		"tiff": .tiff,
		"ts": .ts,
		"ttf": .ttf,
		"txt": .txt,
		"vsd": .vsd,
		"wav": .wav,
		"weba": .weba,
		"webm": .webm,
		"webp": .webp,
		"woff": .woff,
		"woff2": .woff2,
		"xhtml": .xhtml,
		"xls": .xls,
		"xlsx": .xlsx,
		"xml": .xml,
		"xul": .xul,
		"zip": .zip,
		"3gp": ._3gp,
		"3g2": ._3g2,
		"7z": ._7z,
	]
}
