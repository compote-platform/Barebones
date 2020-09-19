
import BarebonesSpecification

public extension Head {

    func read<Generic>(header: Header, map: (String) -> Generic?) throws -> Generic? {
        switch header {
            case .ommitable(let key):
                guard
                    let rawValue = self[key],
                    let value = map(rawValue)
                else { return .none }
                return value
            case .mandatory(let key):
                guard
                    let rawValue = self[key],
                    let value = map(rawValue)
                else { throw APIError.badRequest }
                return value

        }
    }
}
