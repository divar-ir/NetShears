//
//  RequestEvaluatorModifierResponse.swift
//  
//
//  Created by Pouya on 11/4/1400 AP.
//

import Foundation

public struct RequestEvaluatorModifierResponse: RequestEvaluatorActionModifier, Equatable {
    public var response: HTTPResponseModifyModel
    
    public init(response: HTTPResponseModifyModel) {
        self.response = response
    }
    
    public static var storeFileName: String {
        "Response.txt"
    }
    
    public func isActionAllowed(urlRequest: URLRequest) -> Bool {
        URL(string: response.url) == urlRequest.url && urlRequest.httpMethod?.lowercased() == response.httpMethod.lowercased()
    }
    
    public func modify(client: URLProtocolClient?, urlProtocol: URLProtocol) {
        guard let urlResponse = response.response else { return }
        client?.urlProtocol(urlProtocol, didLoad: response.data)
        client?.urlProtocol(urlProtocol, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(urlProtocol)
    }
}
