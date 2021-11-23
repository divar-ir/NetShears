//
//  ThreadSafe.swift
//  
//
//  Created by Ali Moazenzadeh on 11/17/21.
//

import Foundation

final class ThreadSafe<A> {
    private var _value: A
    private let queue = DispatchQueue(label: "ThreadSafe")
    init(_ value: A) {
        self._value = value
    }

    var value: A {
        return queue.sync { _value }
    }

    func atomically(_ transform: (inout A) -> Void) {
        queue.sync {
            transform(&self._value)
        }
    }
}
