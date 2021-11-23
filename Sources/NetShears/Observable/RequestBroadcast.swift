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
    static let shared = RequestBroadcast()

    var delegate = ThreadSafe<RequestBroadcastDelegate?>(nil)

    private init() {}

    func setDelegate(_ newDelegate: RequestBroadcastDelegate) {
        delegate.atomically { delegate in
            delegate = newDelegate
        }
    }

    func removeDelegate() {
        delegate.atomically { delegate in
            delegate = nil
        }
    }

    func newRequestArrived(_ request: NetShearsRequestModel) {
        delegate.atomically { delegate in
            delegate?.newRequestArrived(request)
        }
    }
}
