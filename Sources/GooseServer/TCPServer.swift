//
// Created by color on 4/7/19.
//

import Foundation
import SwiftEvent
import Glibc

let acceptConn: @convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<sockaddr>?, Int32, UnsafeMutableRawPointer?) -> Void = { (listener, fd, address, socklen, arg) in

    guard let t = arg else {
        return
    }

    let tcpServer: EvTCPServer = t.unretainedValue()
    tcpServer.accept(fd)
}

let acceptConnError: @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> Void = { (listener, arg) in

    let err = strerror(errno)
    let errStr = String(cString: err!)
    print("FILE:\(#file): \(errStr)")
}


open class EvTCPServer: Event {

    let loop: EventLoop
    var serverFds: [OpaquePointer] = []
    var delegate: TCPDelegate
    var clients: [Int32: EvConnection] = [:]

    public init(loop: EventLoop, delegate: TCPDelegate) {
        self.loop = loop
        self.delegate = delegate
    }

    public func start(host: String, port: String) {
        var serviceAddressHints = addrinfo()
        serviceAddressHints.ai_family = AF_UNSPEC
        /* Use TCP protocol. */
        serviceAddressHints.ai_socktype = Int32(SOCK_STREAM.rawValue)
        /* Choose IP automatically. */
        serviceAddressHints.ai_flags = AI_PASSIVE
        var serviceAddresses: UnsafeMutablePointer<addrinfo>? = nil

        let eai_error = evutil_getaddrinfo(
                host,
                port,
                &serviceAddressHints,
                &serviceAddresses
        )

        defer {
            evutil_freeaddrinfo(serviceAddresses)
        }

        guard eai_error == 0 else {
            return
        }

        var serviceAddress = serviceAddresses

        while let service = serviceAddress {

            if let listener = evconnlistener_new_bind(loop.evbase,
                    acceptConn, unretained2Opaque(self), LEV_OPT_CLOSE_ON_FREE | LEV_OPT_REUSEABLE, -1, service.pointee.ai_addr, Int32(service.pointee.ai_addrlen)) {
                self.serverFds.append(listener)
                evconnlistener_set_error_cb(listener, acceptConnError)
            }

            serviceAddress = serviceAddresses?.pointee.ai_next

        }
    }

    fileprivate func accept(_ fd: Int32) {
        evutil_make_socket_nonblocking(fd)
        if let b = bufferevent_socket_new(loop.evbase, fd, Int32(BEV_OPT_CLOSE_ON_FREE.rawValue)) {
            let c = EvConnection(ev: b)
            clients[fd] = c
            delegate.onNew(conn: c)
        }

    }

    deinit {
        _ = serverFds.map {
            evconnlistener_free($0)
        }
    }

}

public extension EventLoop {
    public func tcpServer(delegate: TCPDelegate) -> EvTCPServer {
        let server = EvTCPServer(loop: self, delegate: delegate)
        return server
    }
}