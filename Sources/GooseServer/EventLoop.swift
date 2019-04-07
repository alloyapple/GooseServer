//
// Created by color on 4/7/19.
//

import Foundation
import SwiftEvent

public class EventLoop {
    let evbase: OpaquePointer

    public init() {
        evbase = event_base_new()
    }

    public func dispatch() {
        event_base_dispatch(evbase)
    }


    deinit {
        event_base_free(evbase)
    }
}