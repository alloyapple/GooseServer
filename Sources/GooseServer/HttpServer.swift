//
// Created by color on 4/8/19.
//

import Foundation
import SwiftEvent
import Glibc

open class EvHttpServer {

    let loop: EventLoop
    let httpHandle: OpaquePointer
    public init(loop: EventLoop, delegate: TCPDelegate) {
        self.loop = loop
        httpHandle = evhttp_new(loop.evbase)
    }

}