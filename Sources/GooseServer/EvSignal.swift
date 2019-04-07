//
// Created by color on 4/7/19.
//

import Foundation
import Glibc
import SwiftEvent


let signalCallback: @convention(c) (Int32, Int16, UnsafeMutableRawPointer?) -> Void = { (fd, e, arg) in

    guard let t = arg else {
        return
    }

    let timer: EvSignal = t.unretainedValue()
    timer.fire()

}

public typealias SignalFunc = () -> Void

open class EvSignal: Event {

    let signal: Int32
    var signalFunc: SignalFunc?
    let loop: EventLoop

    public init(signal: Int32, loop: EventLoop) {
        self.signal = signal
        self.loop = loop
    }


    public func start(execute: @escaping SignalFunc ) {
        self.ev = event_new(self.loop.evbase, self.signal, Int16(EV_PERSIST) | Int16(EV_SIGNAL), signalCallback, unretained2Opaque(self))
        event_add(ev, nil)

        self.signalFunc = execute
    }

    fileprivate func fire() {
        guard let f = self.signalFunc else {
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
    public func signal(signal: Int32) -> EvSignal {
        let signal = EvSignal(signal: signal, loop: self)
        return signal
    }
}