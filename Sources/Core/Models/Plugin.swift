
public protocol Plugin {

	var work: WebWork { get }
}

public enum PluginRuntimePosition: Int, Hashable {

	case before, after
}

public protocol PluginExtendable {

	@discardableResult
	func plugin(_ plugin: Plugin, when stage: PluginRuntimePosition) -> Self
}
