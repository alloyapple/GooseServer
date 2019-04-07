//
// Created by color on 4/7/19.
//

import Foundation

public protocol TCPDelegate {
    func onNew(conn: EvConnection)
    func onRead(conn: EvConnection)
    func onWrite(conn: EvConnection)
    func onClose(conn: EvConnection)

}