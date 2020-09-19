
import BarebonesSpecification
import BarebonesCore
import BarebonesServer
import BarebonesPlugins

public extension Endpoint
where
    Self: Activity,
    Specification.Input: BodyMaterializable
{
    static var request: Middleware {
        Request(method: Specification.method) { (_, input: Specification.Input) in
            .value(try Self().perform(input).asBody())
        }.api
    }
}

public extension Endpoint
where
    Self: Activity,
    Specification.Input: Materializable
{
    static var request: Middleware {
        Request(method: Specification.method) { (_, input: Specification.Input) in
            .value(try Self().perform(input).asBody())
        }.api
    }
}
