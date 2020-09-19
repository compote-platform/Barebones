
public protocol Activity {

    associatedtype Specification: EndpointSpecification

    var data: String { get }

    init()

    func perform(_ input: Specification.Input) throws -> Specification.Output
}
