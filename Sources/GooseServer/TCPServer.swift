//
// Created by color on 4/7/19.
//

import Foundation
import SwiftEvent
import Glibc


let doAccept: @convention(c) (Int32, Int16, UnsafeMutableRawPointer?) -> Void = { (fd, e, arg) in

    guard let t = arg else {
        return
    }

    let tcpServer: EvTCPServer = t.unretainedValue()
    tcpServer.accept(fd)

}


open class EvTCPServer: Event {

    let loop: EventLoop
    var serverFds: [Int32] = []

    public init(loop: EventLoop) {
        self.loop = loop
    }

    public func start(host: String, port: String) {
        var service_address_hints = addrinfo()
        service_address_hints.ai_family = AF_UNSPEC
        /* Use TCP protocol. */
        service_address_hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
        /* Choose IP automatically. */
        service_address_hints.ai_flags = AI_PASSIVE
        var serviceAddresses: UnsafeMutablePointer<addrinfo>? = nil

        let eai_error = evutil_getaddrinfo(
                host,
                port,
                &service_address_hints,
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
            let listenerSocket = socket(
                    service.pointee.ai_family,
                    service.pointee.ai_socktype,
                    service.pointee.ai_protocol
            )

            evutil_make_socket_nonblocking(listenerSocket)
            evutil_make_listen_socket_reuseable(listenerSocket)
            bind(listenerSocket, service.pointee.ai_addr, service.pointee.ai_addrlen)
            listen(listenerSocket, 1024)
            self.ev = event_new(
                    loop.evbase,
                    listenerSocket,
                    Int16(EV_READ | EV_PERSIST),
                    doAccept,
                    unretained2Opaque(self)
            )

            self.serverFds.append(listenerSocket)

            serviceAddress = serviceAddresses?.pointee.ai_next

        }
    }

    fileprivate func accept(_ fd: Int32) {

    }

}