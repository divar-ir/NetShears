//
//  RequestEvaluatorModifierEndpoint.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/19/21.
//

import Foundation

public struct RequestEvaluatorModifierEndpoint: RequestEvaluatorModifier, Equatable, Codable {

    public var redirectedRequest: RedirectedRequestModel

    public static var storeFileName: String {
        "Modifier.txt"
    }
    
    public init(redirectedRequest: RedirectedRequestModel) {
        self.redirectedRequest = redirectedRequest
    }
    
    public func modify(request: inout URLRequest) {

        if isRequestRedirectable(urlRequest: request) {
            request.modifyURLRequestEndpoint(redirectUrl: redirectedRequest)
        }
    }
    
    public func isActionAllowed(urlRequest: URLRequest) -> Bool {
        return isRequestRedirectable(urlRequest: urlRequest)
    }
    
    func isRequestRedirectable(urlRequest: URLRequest) -> Bool {
        guard let urlString = urlRequest.url?.absoluteString else {
            return false
        }

        if urlString.contains(redirectedRequest.originalUrl) {
            return true
        }
        
        return false
    }
}
