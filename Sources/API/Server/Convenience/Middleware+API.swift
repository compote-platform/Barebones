
import BarebonesSpecification
import BarebonesCore
import BarebonesPlugins

extension Middleware {

    var api: Middleware {
        Middleware(timeout: self.timeout, handler: self.handler, plugins: [
            .before: [
                HTTPHeadersReader(Self.apiHeaders),
            ] + (self.plugins[.before] ?? []),
            .after: [
                ErrorDecorator(format: .json),
            ] + (self.plugins[.after] ?? [])
        ])
    }

    static var apiHeaders: [Header] = [
        .ommitable("contentType")
    ]
}
