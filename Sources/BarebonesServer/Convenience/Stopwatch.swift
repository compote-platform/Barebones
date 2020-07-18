
import Foundation
import Dispatch

public enum Stopwatch {

    public typealias Time = UInt64

    case onHold
    case running(startedOn: Time)
    case stop(startedOn: Time, endedOn: Time)
}

public extension Stopwatch {

    var runtime: TimeInterval {
        TimeInterval(machAbsoluteRuntime) / Self.nanosecondsPerSecond
    }

    @discardableResult
    func start() -> Stopwatch { .running(startedOn: Self.now) }

    @discardableResult
    func stop() -> Stopwatch {
        guard case .running(let start) = self else { return self }
        return .stop(startedOn: start, endedOn: Self.now)
    }

    @discardableResult
    func reset() -> Stopwatch { .onHold }
}

private extension Stopwatch {

    static let nanosecondsPerSecond: TimeInterval = 1000000000
    static var now: Time { DispatchTime.now().uptimeNanoseconds }

    var machAbsoluteRuntime: Time {
        switch self {
            case .onHold: return 0
            case .running: return stop().machAbsoluteRuntime
            case .stop(let start, let end): return  end - start
        }
    }
}

extension Stopwatch: CustomStringConvertible {

    public var description: String {
        switch self {
            case .onHold: return "Not yet started"
            case .running: return "Running for \(runtime) seconds"
            case .stop: return "Ended, was running \(runtime) seconds"
        }
    }
}
