//
// Created by color on 4/7/19.
//

import Foundation
import SwiftEvent

public class EvConnection {

    let ev: UnsafeMutablePointer<bufferevent>

    public init(ev: UnsafeMutablePointer<bufferevent>) {
        self.ev = ev
    }

    public func read() {

    }

    public func write(_ buffer: [UInt8]) -> Int32 {
        var _buffer = buffer
        return bufferevent_write(self.ev, &_buffer, buffer.count)
    }

}