//
//  URLSessionConfiguration+Extension.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import Foundation

extension URLSessionConfiguration {
    
    @objc func fakeProtocolClasses() -> [AnyClass]? {
        guard let fakeProtocolClasses = self.fakeProtocolClasses() else {
            return []
        }
        var originalProtocolClasses = fakeProtocolClasses.filter {
            return $0 != NetworkInterceptorUrlProtocol.self && $0 != NetworkLoggerUrlProtocol.self && $0 != NetwrokListenerUrlProtocol.self
        }
        if NetShears.shared.loggerEnable {
            originalProtocolClasses.insert(NetworkLoggerUrlProtocol.self, at: 0)
        }
        if NetShears.shared.listenerEnable {
            originalProtocolClasses.insert(NetwrokListenerUrlProtocol.self, at: 0)
        }
        if NetShears.shared.interceptorEnable {
            originalProtocolClasses.insert(NetworkInterceptorUrlProtocol.self, at: 0)
        }
        return originalProtocolClasses
    }
    
}
