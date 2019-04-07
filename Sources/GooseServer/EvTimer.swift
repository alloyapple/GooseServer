//
// Created by color on 4/7/19.
//

import Foundation
import SwiftEvent


let timerCallback: @convention(c) (Int32, Int16, UnsafeMutableRawPointer?) -> Void = { (fd, e, arg) in

    guard let t = arg else {
        return
    }

    let timer: EvTimer = t.unretainedValue()
    timer.fire()

}


public typealias TimeoutFunc = () -> Void

open class EvTimer: Event {
    let time: timeval
    var timeoutFunc: TimeoutFunc?
    let loop: EventLoop

    public init(time: timeval, loop: EventLoop) {
        self.time = time
        self.loop = loop
    }


    public func start(execute: @escaping TimeoutFunc ) {
        self.ev = event_new(self.loop.evbase, -1, Int16(EV_PERSIST), timerCallback, unretained2Opaque(self))
        var t = self.time
        event_add(self.ev, &t)

        self.timeoutFunc = execute
    }

    fileprivate func fire() {
        guard let f = self.timeoutFunc else {
            return
        }

        f()
    }

    public func stop() {
        event_del(self.ev)
        self.ev = nil
    }

    deinit {
        if let e = self.ev {
            event_del(e)
        }

    }
}

public extension EventLoop {
    public func timer(time: timeval) -> EvTimer {
        let timer = EvTimer(time: time, loop: self)
        return timer
    }
}