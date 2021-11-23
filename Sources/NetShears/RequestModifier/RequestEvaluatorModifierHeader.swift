//
//  RequestEvaluatorModifierHeader.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/19/21.
//

import Foundation

public struct RequestEvaluatorModifierHeader: RequestEvaluatorModifier, Equatable, Codable {
    
    public var header: HeaderModifyModel
    
    public static var storeFileName: String {
        "Header.txt"
    }
    
    public init(header: HeaderModifyModel) {
        self.header = header
    }
    
    public func modify(request: inout URLRequest) {
        request.modifyURLRequestHeader(header: header)
    }
    
    public func isActionAllowed(urlRequest: URLRequest) -> Bool {
        return true
    }
}
