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

}