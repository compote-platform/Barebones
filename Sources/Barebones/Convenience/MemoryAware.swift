
public typealias Memory = Int64

public extension Memory {

    static func bytes(_ size: Memory) -> Memory { size }
    static func kb(_ size: Memory) -> Memory { size * 1024 }
    static func mb(_ size: Memory) -> Memory { size * 1024 * 1024 }
    static func gb(_ size: Memory) -> Memory { size * 1000 * 1024 * 1024 }
}

extension Memory {

    public var memoryDescription: String {
        memoryAwarebyteCountFormatter.string(fromByteCount: self)
    }
}

/// A type which is responsible and can account for it's size in memory
public protocol MemoryAware {

    /// Size taken by a specific instance of type
    var memorySize: Memory { get }
}

public extension MemoryAware {

    /// A description of current memory size
    var memoryDescription: String { memorySize.memoryDescription }
}

import Foundation

internal var memoryAwarebyteCountFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
    formatter.countStyle = .memory
    return formatter
}()

extension Data: MemoryAware {

    public var memorySize: Memory {
        Memory(count)
    }
}

extension Array: MemoryAware where Element: MemoryAware {

    public var memorySize: Memory {
        let size = Memory(MemoryLayout.size(ofValue: self))
        return Memory(
            map { $0.memorySize }.reduce(size, +)
        )
    }
}

extension Optional: MemoryAware where Wrapped: MemoryAware {

    public var memorySize: Memory {
        let size = Memory(MemoryLayout.size(ofValue: self))
        guard case .some(let wrapped) = self else { return size }
        return wrapped.memorySize + size
    }
}

import Files

public extension Memory {

    static func totalRAM() -> Memory {
        Int64(ProcessInfo.processInfo.physicalMemory)
    }
    static func freeDiskSpace() -> Memory {
        guard
            let folder = try? Folder.home.subfolder(named: "Documents"),
            let attributes = try? FileManager.default.attributesOfFileSystem(forPath: folder.path),
            let freeSize = attributes[.systemFreeSize] as? NSNumber
            else { return 0 }
        return freeSize.int64Value
    }
}
