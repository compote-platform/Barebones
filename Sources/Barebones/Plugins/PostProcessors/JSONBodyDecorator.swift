
import Foundation
import PromiseKit

public struct JSONBodyDecorator: Plugin {

    public init() {}

    public var work: WebWork {
        { (worker: WebWorker) in
            guard case .json = worker.contentType else { return .value(()) }

            let options: JSONSerialization.WritingOptions
            #if DEBUG
            options = .prettyPrinted
            #else
            options = []
            #endif

            worker.data = try JSONSerialization.data(withJSONObject: worker.body, options: options)
            return .value(())
        }
    }
}
