//
//  NetShearsModfierProtocol.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/19/21.
//

import Foundation

public protocol RequestEvaluator {
    func isActionAllowed(urlRequest: URLRequest) -> Bool
}

public protocol RequestModifier {
    func modify(request: inout URLRequest)
}

public protocol RequestEvaluatorModifier : RequestEvaluator, RequestModifier {}


