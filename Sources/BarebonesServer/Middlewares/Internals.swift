
import Foundation
import PromiseKit
import Files

open class Internals: Router {

    public init(journal journalFile: File) {
		super.init()
		
        route("journal", Request { worker -> Promise<Body> in
            let journal = try Journal.from(file: journalFile, length: 160)
            let output = journal.log.reversed().map {
                $0.marker.rawValue + " " + "\($0.occuredAt)" + " " + $0.text
            }
            return .value(["response": output])
        })
        route("stats", Request { worker -> Promise<Body> in
            let file = journalFile
            let journal = try Journal.from(file: file)

            let logSize = try file.read().memoryDescription
            let cacheSize = Cache.shared.memoryDescription
            let requests = journal.log
                .map(\.description)
                .filter { $0.contains("finished response") || $0.contains("failed response") }
                .count
            let uptimes = journal.log
                .map(\.description)
                .filter { $0.contains("starting server") }
                .count / 2

            let records = journal.log
                .split(whereSeparator: { $0.marker == Journal.Marker.separator })
                .map(Array.init)
                .map {
                    [
                        $0.first(where: { $0.text.contains("serving path") }),
                        $0.last(where: { $0.text.contains("finished response") || $0.text.contains("failed response") }),
                        ].compactMap { $0}
            }
            .filter { $0.count == 2 }
            .map { (start: $0.first!, end: $0.last!) }

            var durationsHeatMap = [String: [TimeInterval]]()

            records.forEach { start, end in
                let path = start.text.components(separatedBy: "serving path ").last!
                var durations = durationsHeatMap[path] ?? []
                durations.append(end.occuredAt - start.occuredAt)
                durationsHeatMap[path] = durations
            }

            let heatMap: [[String: TimeInterval]] = durationsHeatMap.compactMap { path, durations in
                guard durations.count > 0 else { return nil }
                return [path: durations.reduce(0.0, +) / Double(durations.count) ]
            }

            return .value([
                "response": [
                    "stats": [
                        "logSize": logSize,
                        "cacheSize": cacheSize,
                        "uptimes": uptimes,
                        "requests": requests,
                    ],
                    "requestHeatMap": heatMap,
                ]
            ])
        })
	}
}
