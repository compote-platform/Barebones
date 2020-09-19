
import BarebonesSpecification

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
