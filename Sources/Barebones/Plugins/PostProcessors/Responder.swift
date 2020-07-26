
import Foundation
import PromiseKit
import Embassy
import Ambassador

public final class Responder: Plugin {

    typealias StartResponse = (String, [(String, String)]) -> Void
    typealias SendBody = (Data) -> Void

    internal var startResponse: StartResponse!
    internal var sendBody: SendBody!
    internal var shouldRespond: Bool = true

    public init() {}

    public var work: WebWork {
        { [unowned self] (worker: WebWorker) in
            return try [
                { [unowned worker] _ in
                    worker.journal.log(.todo("📤 sending response " + "(\(worker.contentType))"))
                    return .value(())
                },
                { [unowned worker] _ in
                    let promise = Promise<Void>.pending()
                    let loop: EventLoop = try worker.environ.read(key: .eventLoop)

                    let code = worker.statusCode
                    let contentType = worker.contentType.rawValue
                    let data = worker.data
                    let environ = worker.environ

                    guard
                        self.shouldRespond,
                        let startResponse = self.startResponse,
                        let sendBody = self.sendBody
                        else {
                            return .value(())
                        }

                    loop.call {
                        DataResponse(
                            statusCode: code,
                            contentType: contentType
                        ) { _, sendData in
                            sendData(data)
                            promise.resolver.fulfill(())
                        }.app(environ, startResponse: startResponse, sendBody: sendBody)
                    }
                    return promise.promise
                },
                { [unowned worker] _ in
                    worker.journal.log(.done("📤 sending response " + "(\(worker.contentType))"))
                    return .value(())
                },
                log(.event("💌 done sending response"))
            ].process(worker)
        }
    }
}
