
import Foundation
import Files

public final class Journal {

    public static let shared: Journal = {
        return Journal()
    }()

    public private(set) var log: [Entry]
    public private(set) var stopwatch: Stopwatch = .onHold

    public init(log: [Entry] = []) {
        self.log = log
        stopwatch = stopwatch.start()
    }

    @discardableResult
    public func log(_ entries: Entry...) -> Self {
        Journal.queue.sync {
            _ = entries.map(log)
        }
        return self
    }
}

extension Journal {

    public static let queue = DispatchQueue(label: "journal")

    public func extend(with journal: Journal) {
        journal.log.forEach { log($0) }
    }

    @discardableResult
    private func log(_ entry: Entry) -> Self {
        if entry.occuredAt == 0 {
            var updated = entry
            updated.occuredAt = stopwatch.runtime
            log.append(updated)
        } else {
            log.append(entry)
        }
        return self
    }
}

extension Array: RawRepresentable where Element == Journal.Entry {

    public init(rawValue: String) {
        self = rawValue.components(separatedBy: "\n").compactMap { Journal.Entry(rawValue: $0) }
    }

    public var rawValue: String {
        map { $0.rawValue }.joined(separator: "\n")
    }
}

extension Journal.Entry: RawRepresentable {

    public init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: "\t")

        guard
            parts.count >= 3,
            let rawMarker = parts.first,
            let occurenceString = parts.dropFirst(1).first,
            let marker = Journal.Marker(rawValue: rawMarker),
            let occurence = TimeInterval(occurenceString)
            else { return nil }

        let text = parts.dropFirst(2).joined(separator: " ")

        self = .entry(marker: marker, text: text, occuredAt: occurence)
    }

    public var rawValue: String {
        marker.rawValue + "\t" + "\(occuredAt)" + "\t" + text
    }
}

extension Journal {

    public enum Entry {

        case entry(marker: Marker, text: String, occuredAt: TimeInterval)

        public var marker: Marker {
            switch self {
                case .entry(let marker, _, _): return marker
            }
        }

        public var text: String {
            switch self {
                case .entry(_, let text, _): return text
            }
        }

        public var occuredAt: TimeInterval {
            get {
                switch self {
                    case .entry(_, _, let time): return time
                }
            }
            set {
                switch self {
                    case .entry(let marker, let text, _):
                        self = .entry(marker: marker, text: text, occuredAt: newValue)
                }
            }
        }

        public static func note(_ note: String) -> Entry {
            .entry(marker: .note, text: note, occuredAt: 0)
        }

        public static func todo(_ todo: String) -> Entry {
            .entry(marker: .todo, text: todo, occuredAt: 0)
        }

        public static func done(_ done: String) -> Entry {
            .entry(marker: .done, text: done, occuredAt: 0)
        }

        public static func event(_ event: String) -> Entry {
            .entry(marker: .event, text: event, occuredAt: 0)
        }

        public static func custom(_ marker: Marker, text: String) -> Entry {
            .entry(marker: marker, text: text, occuredAt: 0)
        }

        public static var separator: Entry {
            .entry(
                marker: .separator,
                text: Array(repeating: Journal.Marker.separator.rawValue, count: 16).joined(),
                occuredAt: 0
            )
        }
    }
}

extension Journal {

    public enum Marker: ExpressibleByStringLiteral, RawRepresentable, Codable, Equatable, Hashable {

        public typealias StringLiteralType = String

        case raw(String)

        public static let wildcard: Marker = "*"
        public static let note: Marker = "⁃"
        public static let todo: Marker = "☐"
        public static let done: Marker = "✕"
        public static let event: Marker = "∙"
        public static let separator: Marker = "〰"

        public init(stringLiteral value: String) {
            guard !value.isEmpty else { fatalError("Empty marker is unallowed") }
            self = .raw(value)
        }

        public init?(rawValue: String) {
            guard !rawValue.isEmpty else { return nil }
            self = .raw(rawValue)
        }

        public var rawValue: String {
            switch self {
                case .raw(let raw): return raw
            }
        }
    }
}

extension Journal.Entry: CustomStringConvertible {

    public var description: String { rawValue }
}

extension Journal {

    public static func from(file: File, length: UInt = 0) throws -> Journal {
        var journal = Journal()
        try Journal.queue.sync {
            let raw = try file.readAsString()
            let lines = raw.components(separatedBy: "\n")

            guard !raw.isEmpty else { return }
            guard length != 0, lines.count > length else {
                journal = Journal(log: [Journal.Entry](rawValue: raw))
                return
            }

            let trimmed = lines
                .dropFirst(lines.count - Int(length))
                .joined(separator: "\n")

            journal = Journal(log: [Journal.Entry](rawValue: trimmed))
        }
        return journal
    }

    public func dump(to function: (String) -> Void) {
        guard !log.isEmpty else { return }

        function(log.rawValue)
        log = []
    }

    public func dump(to file: File) throws {
        guard !log.isEmpty else { return }

        log(.event("📼 dumping journal"))

        try Journal.queue.sync {
            try file.append("\n")
            try file.append(log.rawValue)
            log = []
        }
    }
}
