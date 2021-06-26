//
//  URLSessionConfiguration+Extension.swift
//  
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import Foundation

extension URLSessionConfiguration {
    
    @objc func fakeProcotolClasses() -> [AnyClass]? {
        guard let fakeProcotolClasses = self.fakeProcotolClasses() else {
            return []
        }
        var originalProtocolClasses = fakeProcotolClasses.filter {
            return $0 != NetworkRequestSniffableUrlProtocol.self
        }
        originalProtocolClasses.insert(NetworkRequestSniffableUrlProtocol.self, at: 0)
        return originalProtocolClasses
    }
    
}
