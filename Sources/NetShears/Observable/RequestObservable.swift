//
//  RequestObservable.swift
//  
//
//  Created by Ali Moazenzadeh on 11/17/21.
//

import Foundation

protocol RequestObserverProtocol {
    func newRequestArrived(_ request: NetShearsRequestModel)
}

final class RequestObserver: RequestObserverProtocol {
    let options: [RequestObserverProtocol]

    init(options: [RequestObserverProtocol]) {
        self.options = options
    }

    func newRequestArrived(_ request: NetShearsRequestModel) {
        options.forEach {
            $0.newRequestArrived(request)
        }
    }
}
