//
//  RequestBroadcast.swift
//  
//
//  Created by Ali Moazenzadeh on 11/17/21.
//

import Foundation

public protocol RequestBroadcastDelegate: AnyObject {
    func newRequestArrived(_ request: NetShearsRequestModel)
}

public final class RequestBroadcast: RequestObserverProtocol {
    static public let shared = RequestBroadcast()

    private var delegates = ThreadSafe<NSHashTable<AnyObject>>(.weakObjects())

    private init() {}

    public func addDelegate(_ newDelegate: RequestBroadcastDelegate) {
        delegates.atomically { delegates in
            delegates.add(newDelegate)
        }
    }

    public func removeDelegate(_ delegateToRemove: RequestBroadcastDelegate) {
        delegates.atomically { delegates in
            delegates.remove(delegateToRemove)
        }
    }

    func newRequestArrived(_ request: NetShearsRequestModel) {
        delegates.atomically { delegates in
            delegates.allObjects.reversed().forEach { ($0 as! RequestBroadcastDelegate).newRequestArrived(request) }
        }
    }
}
