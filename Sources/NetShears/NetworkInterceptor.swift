//
//  NetworkInterceptor.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation


@objc class NetworkInterceptor: NSObject {
    
    @objc static let shared = NetworkInterceptor()
    let networkRequestInterceptor = NetworkRequestInterceptor()

    func shouldRequestModify(urlRequest: URLRequest) -> Bool {
        for modifer in NetShears.shared.config.modifiers {
            if modifer.isActionAllowed(urlRequest: urlRequest) {
                return true
            }
        }
        return false
    }
}

