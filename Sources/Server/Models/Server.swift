
import Journal
import Foundation
import Embassy
import Ambassador
import PromiseKit

public final class Server {

    public let interface: String
    public let name: String
    public let port: UInt16

    public let queue: DispatchQueue
    public let app: WebApp

    public private(set) var loop: EventLoop?
    public private(set) var server: DefaultHTTPServer?

    public init(name: String, interface: String, port: UInt16, on queue: DispatchQueue, app: WebApp) {
        self.name = name
        self.interface = interface
        self.port = port
        self.queue = queue
        self.app = app
    }

    public func startDetached() -> Promise<Void> {
        Promise { resolver in
            queue.async { [weak self] in
                self?.startServer.perform()
                resolver.fulfill(())
                self?.loop?.safeRunForever()
            }
        }
    }

    public func start() {
        startServer.perform()
        loop?.safeRunForever()
    }

    public func stop() {
        stopServer.perform()
    }

    private var startServer: DispatchWorkItem {
        DispatchWorkItem { [weak self] in
            guard let this = self else { return }
            do {
                Journal.shared.log(.todo("🚀 starting server: \(this.name) on port: \(this.port)"))

                this.loop = try SelectorEventLoop(selector: try SelectSelector())
                this.server = DefaultHTTPServer(eventLoop: this.loop!, interface: this.interface, port: Int(this.port), app: this.app.app)
                try this.server!.start()

                Journal.shared.log(.done("🚀 starting server: \(this.name) on port: \(this.port)"))
            } catch {
                this.server = nil
                this.loop = nil
                Journal.shared.log(.event("⚠️ failed to start server: \(this.name) on port: \(this.port) , error: \(error)"))
            }
        }
    }

    private var stopServer: DispatchWorkItem {
        DispatchWorkItem { [weak self] in
            guard let this = self, let server = this.server, let loop = this.loop else { return }

            Journal.shared.log(.todo("⛔️ stopping server: \(this.name) on port: \(this.port)"))
            server.stopAndWait()
            this.server = nil
            loop.safeStop()
            this.loop = nil
            Journal.shared.log(.done("⛔️ stopping server: \(this.name) on port: \(this.port)"))
        }
    }
}

fileprivate extension EventLoop {

    func safeRunForever() {
        guard !running else { return }
        runForever()

    }

    func safeStop() {
        guard !running else { return }
        stop()
    }
}


