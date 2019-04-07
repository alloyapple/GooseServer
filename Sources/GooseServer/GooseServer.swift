struct GooseServer {
    var text = "Hello, World!"
}


public func unretained2Opaque(_ object: AnyObject) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(object).toOpaque()
}

public func retained2Opaque(_ object: AnyObject) -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(object).toOpaque()
}

public extension UnsafeRawPointer {
    func unretainedValue<T: AnyObject>() -> T {
        return Unmanaged<T>.fromOpaque(self).takeUnretainedValue()
    }

    func retainedValue<T: AnyObject>() -> T {
        return Unmanaged<T>.fromOpaque(self).takeRetainedValue()
    }
}

public extension UnsafeMutableRawPointer {
    func unretainedValue<T: AnyObject>() -> T {
        return Unmanaged<T>.fromOpaque(self).takeUnretainedValue()
    }

    func retainedValue<T: AnyObject>() -> T {
        return Unmanaged<T>.fromOpaque(self).takeRetainedValue()
    }
}