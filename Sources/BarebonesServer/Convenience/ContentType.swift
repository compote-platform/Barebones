
public enum ContentType: String, RawRepresentable, Codable {

	public static var none: ContentType { .bin }
	public static var allowedStatic: [ContentType] = [
		.jpg,
		.png,
		.svg,
		.gif,

		.xml,
		.json,

		.txt,

		.html,
		.js,
		.css,
		.ico,
	]

	case aac = "audio/aac"
	case abw = "application/x-abiword"
	case arc = "application/x-freearc"
	case avi = "video/x-msvideo"
	case azw = "application/vnd.amazon.ebook"
	case bin = "application/octet-stream"
	case bmp = "image/bmp"
	case bz = "application/x-bzip"
	case bz2 = "application/x-bzip2"
	case csh = "application/x-csh"
	case css = "text/css"
	case csv = "text/csv"
	case doc = "application/msword"
	case docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
	case eot = "application/vnd.ms-fontobject"
	case epub = "application/epub+zip"
	case gz = "application/gzip"
	case gif = "image/gif"
	case html = "text/html"
	case ico = "image/vnd.microsoft.icon"
	case ics = "text/calendar"
	case jar = "application/java-archive"
	case jpg = "image/jpeg"
	case js = "text/javascript"
	case json = "application/json"
	case jsonld = "application/ld+json"
	case midi = "audio/midi audio/x-midi"
	case mp3 = "audio/mpeg"
	case mpeg = "video/mpeg"
	case mpkg = "application/vnd.apple.installer+xml"
	case odp = "application/vnd.oasis.opendocument.presentation"
	case ods = "application/vnd.oasis.opendocument.spreadsheet"
	case odt = "application/vnd.oasis.opendocument.text"
	case oga = "audio/ogg"
	case ogv = "video/ogg"
	case ogx = "application/ogg"
	case opus = "audio/opus"
	case otf = "font/otf"
	case png = "image/png"
	case pdf = "application/pdf"
	case php = "application/php"
	case ppt = "application/vnd.ms-powerpoint"
	case pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
	case rar = "application/vnd.rar"
	case rtf = "application/rtf"
	case sh = "application/x-sh"
	case svg = "image/svg+xml"
	case swf = "application/x-shockwave-flash"
	case tar = "application/x-tar"
	case tiff = "image/tiff"
	case ts = "video/mp2t"
	case ttf = "font/ttf"
	case txt = "text/plain"
	case vsd = "application/vnd.visio"
	case wav = "audio/wav"
	case weba = "audio/webm"
	case webm = "video/webm"
	case webp = "image/webp"
	case woff = "font/woff"
	case woff2 = "font/woff2"
	case xhtml = "application/xhtml+xml"
	case xls = "application/vnd.ms-excel"
	case xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
	case xml = "application/xml"
	case xul = "application/vnd.mozilla.xul+xml"
	case zip = "application/zip"
	case _3gp = "video/3gpp"
	case _3g2 = "video/3gpp2"
	case _7z = "application/x-7z-compressed"
}

