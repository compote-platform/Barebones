
import Foundation
import PromiseKit
import Embassy
import Ambassador

public final class Responder: Plugin {

    public typealias StartResponse = (String, [(String, String)]) -> Void
    public typealias SendBody = (Data) -> Void

    public var startResponse: StartResponse!
    public var sendBody: SendBody!
    public var shouldRespond: Bool = true

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
                            promise.resolver.fulfill(())
                            return promise.promise
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
