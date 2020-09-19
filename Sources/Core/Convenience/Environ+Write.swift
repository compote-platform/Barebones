
import BarebonesSpecification

public extension Environ {

    mutating func write(value: Any?, key: String) {
        self[key] = value
    }
}
