
import BarebonesSpecification

public extension Environ {

    func read<Generic>(key: EnvironKey) throws -> Generic {
        guard let value = self[key.rawValue] as? Generic else {
            throw APIError.typeMismatchOrMissingEnvironValueFor(key: key)
        }
        return value
    }
}
