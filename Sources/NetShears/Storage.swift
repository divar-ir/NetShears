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
    
    var requests: [NetShearsRequestModel] = []
    
    func saveRequest(request: NetShearsRequestModel?){
        guard request != nil else {
            return
        }
        
        if let index = requests.firstIndex(where: { (req) -> Bool in
            return request?.id == req.id ? true : false
        }){
            requests[index] = request!
        }else{
            requests.insert(request!, at: 0)
        }
        NotificationCenter.default.post(name: NSNotification.Name.NewRequestNotification, object: nil)
    }

    func clearRequests() {
        requests.removeAll()
    }
}
