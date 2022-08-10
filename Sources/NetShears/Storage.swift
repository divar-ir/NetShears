//
//  Storage.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//
//

import Foundation

final class Storage: NSObject {

    static let shared: Storage = Storage()
    
    private(set) var requests: [NetShearsRequestModel] = []

    var filteredRequests: [NetShearsRequestModel] {
        return getFilteredRequests()
    }

    func saveRequest(request: NetShearsRequestModel?){
        guard request != nil else {
            return
        }
        
        if let index = requests.firstIndex(where: { (req) -> Bool in
            return request?.id == req.id ? true : false
        }) {
            requests[index] = request!
        } else {
            requests.insert(request!, at: 0)
        }
        NotificationCenter.default.post(name: NSNotification.Name.NewRequestNotification, object: nil)
    }

    func clearRequests() {
        requests.removeAll()
    }

    private func getFilteredRequests() -> [NetShearsRequestModel] {
        guard case Ignore.enabled(let ignoreHandler) = NetShears.shared.ignore else {
            return requests
        }
        let filteredRequests = requests.filter { ignoreHandler($0) == false }
        return filteredRequests
    }

}
