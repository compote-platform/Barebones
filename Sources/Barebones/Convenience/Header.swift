
public enum Header: RawRepresentable {

    /// the ones which are required for processing - will throw
    case mandatory(String)
    /// the ones which are ommitable by processing - won't ever throw
    case ommitable(String)

    public init(rawValue: String) {
        self = .ommitable(rawValue)
    }

    public var rawValue: String {
        switch self {
            case .mandatory(let header): return header
            case .ommitable(let header): return header
        }
    }
}
