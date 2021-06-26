//
//  NetworkInterceptor.swift
// 
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation


@objc public class NetworkInterceptor: NSObject {
    
    @objc public static let shared = NetworkInterceptor()
    let networkRequestInterceptor = NetworkRequestInterceptor()
    
    public func startRecording(){
        self.networkRequestInterceptor.startRecording()
    }
    
    public func stopRecording(){
        self.networkRequestInterceptor.stopRecording()
    }
    
    public func shouldRequestModify(urlRequest: URLRequest) -> Bool {
        for modifer in NetShears.shared.config.modifiers {
            if modifer.isActionAllowed(urlRequest: urlRequest) {
                return true
            }
        }
        return false
    }
    
}

