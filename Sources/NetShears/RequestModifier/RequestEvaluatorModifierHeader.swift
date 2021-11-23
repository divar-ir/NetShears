//
//  RequestEvaluatorModifierHeader.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/19/21.
//

import Foundation

public struct RequestEvaluatorModifierHeader: RequestEvaluatorModifier, Equatable, Codable {
    
    var header: HeaderModifyModel
    
    static var storeFileName: String {
        "Header.txt"
    }
    
    init(header: HeaderModifyModel) {
        self.header = header
    }
    
    func modify(request: inout URLRequest) {
        request.modifyURLRequestHeader(header: header)
    }
    
    func isActionAllowed(urlRequest: URLRequest) -> Bool {
        return true
    }
}
