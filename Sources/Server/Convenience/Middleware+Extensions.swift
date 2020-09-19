
import BarebonesCore
import BarebonesSpecification
import BarebonesPlugins

extension Middleware {

    @discardableResult
    public func expects(headers: [Header]) -> Self {
        plugin(HTTPHeadersReader(headers))
    }

    @discardableResult
    public func expectsJSONBody() -> Self {
        expectsBody().plugin(JSONBodyParser())
    }

    @discardableResult
    public func expectsBody() -> Self {
        plugin(RawBodyReader(timeout: timeout))
    }
}

extension Middleware {

    public static func router(_ configuration: (Router) -> Void) -> Router {
        let router = Router()
        configuration(router)
        return router
    }
}
