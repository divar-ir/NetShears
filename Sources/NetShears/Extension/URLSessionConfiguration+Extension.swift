//
//  URLSessionConfiguration+Extension.swift
//  NetShears
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
            return $0 != NetworkInterceptorUrlProtocol.self && $0 != NetworkLoggerUrlProtocol.self
        }
        originalProtocolClasses.insert(NetworkInterceptorUrlProtocol.self, at: 0)
        originalProtocolClasses.insert(NetworkLoggerUrlProtocol.self, at: 0)
        return originalProtocolClasses
    }
    
}
