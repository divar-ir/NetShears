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
    private let accessQueue = DispatchQueue(label: "com.netshears.queue", attributes: .concurrent)

    private(set) var requests: [NetShearsRequestModel] = []

    var filteredRequests: [NetShearsRequestModel] {
        getFilteredRequests()
    }

    func saveRequest(request: NetShearsRequestModel) {
        accessQueue.async(flags: .barrier) { [weak self] in
            guard let self else {
                return
            }
            if let index = self.requests.firstIndex(where: { (req) -> Bool in
                return request.id == req.id ? true : false
            }) {
                self.requests[index] = request
            } else {
                self.requests.insert(request, at: 0)
            }
            NotificationCenter.default.post(name: NSNotification.Name.NewRequestNotification, object: nil)
        }
    }

    func clearRequests() {
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.requests.removeAll()
        }
    }

    private func getFilteredRequests() -> [NetShearsRequestModel] {
        var filteredRequestes = [NetShearsRequestModel]()
        accessQueue.sync {
            guard case Ignore.enabled(let ignoreHandler) = NetShears.shared.ignore else {
                filteredRequestes =  requests
                return
            }
            filteredRequestes = requests.filter { ignoreHandler($0) == false }

        }
        return filteredRequestes

    }

}
