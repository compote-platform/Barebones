
import Dispatch
import Foundation

public final class Cache: MemoryAware {

	public struct Cached: Codable {

		public let data: Data
		public let contentType: ContentType
		public let createdAt: Date

		public init(data: Data, contentType: ContentType, createdAt: Date = Date()) {
			self.data = data
			self.contentType = contentType
			self.createdAt = createdAt
		}
	}

    public static var shared: Cache = Cache(size: .mb(100))

	public let allowedSize: Memory
	private var cache = [String: Cached]()

	public init(size: Memory) {
		allowedSize = size
	}

	public var memorySize: Memory {
		let size = Memory(MemoryLayout.size(ofValue: self))
		return cache.map { _, value in
			value
		}.map { $0.data.memorySize }.reduce(0, +) + size
	}

	private let semaphore = DispatchSemaphore(value: 1)

	public func has(key: String) -> Bool {
		_ = semaphore.wait(timeout: DispatchTime.distantFuture)
		defer {
			semaphore.signal()
		}
		guard case .some = cache.index(forKey: key) else { return false}
		return true
	}

	public func write(key: String, data: Data, contentType: ContentType) {
		_ = semaphore.wait(timeout: DispatchTime.distantFuture)
		defer {
			semaphore.signal()
		}

		cache[key] = Cached(data: data, contentType: contentType)
	}

	public func erase(key: String) {
		_ = semaphore.wait(timeout: DispatchTime.distantFuture)
		defer {
			semaphore.signal()
		}

		guard let index = cache.index(forKey: key) else { return }

		cache.remove(at: index)
	}

	public func read(key: String) -> Cached? {
		_ = semaphore.wait(timeout: DispatchTime.distantFuture)
		defer {
			semaphore.signal()
		}

		return cache[key]
	}

	public var isFilled: Bool {
		return memorySize > allowedSize
	}
}

public final class Cachier: Plugin {

	private let cache: Cache

	public init(cache: Cache = .shared) {
		self.cache = cache
	}

	public var work: WebWork {
		{ [unowned self] (worker: WebWorker) in
			let key: String = try worker.environ.read(key: .path)

			if case .preprocess = worker.stage, let cached = self.cache.read(key: key) {
                if
                    let headers: Head = try? worker.environ.read(key: .parsedHeaders),
                    let cacheControl = headers["Http-Cache-Control"],
                    cacheControl == "no-cache"
                {
                    return .value(())
                }

				worker.data = cached.data
				worker.contentType = cached.contentType
				worker.journal
					.log(.event("💿 read cache: " + key))
					.log(.note("💽 cache size: " + cached.data.memoryDescription))

				worker.stage = .postprocess
			}
			
			if case .postprocess = worker.stage, !worker.data.isEmpty, !self.cache.has(key: key) {
                if
                    let headers: Head = try? worker.environ.read(key: .parsedHeaders),
                    let cacheControl = headers["Http-Cache-Control"],
                    cacheControl == "no-cache"
                {
                    return .value(())
                }

				guard !self.cache.isFilled else {
					worker.journal.log(.note("📦 filled cache, size: "
						+ self.cache.memoryDescription + " / "
						+ self.cache.allowedSize.memoryDescription
					))
					return .value(())
				}

				worker.journal
					.log(.event("🔥 writing to cache: " + key))
					.log(.note("💽 cache size: "
						+ self.cache.memoryDescription + " / "
						+ self.cache.allowedSize.memoryDescription
					))

				self.cache.write(key: key, data: worker.data, contentType: worker.contentType)
			}

			return .value(())
		}
	}
}
