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

public protocol RequestEvaluatorModifier : RequestEvaluator, RequestModifier, Codable {
    static var storeFileName: String { get }
}

extension Array where Element == RequestEvaluatorModifier {
    func store() {
        let headers: [RequestEvaluatorModifierHeader] = compactMap { $0 as? RequestEvaluatorModifierHeader }
        let endpoints: [RequestEvaluatorModifierEndpoint] = compactMap { $0 as? RequestEvaluatorModifierEndpoint }
        PersistHelper.store(headers, as: RequestEvaluatorModifierHeader.storeFileName)
        PersistHelper.store(endpoints, as: RequestEvaluatorModifierEndpoint.storeFileName)
    }

    func retrieveFromDisk() -> [RequestEvaluatorModifier] {
        var modifiers = [RequestEvaluatorModifier]()
        modifiers.append(contentsOf: PersistHelper.retrieve(RequestEvaluatorModifierHeader.storeFileName, as: [RequestEvaluatorModifierHeader].self) ?? [])
        modifiers.append(contentsOf: PersistHelper.retrieve(RequestEvaluatorModifierEndpoint.storeFileName, as: [RequestEvaluatorModifierEndpoint].self) ?? [])
        return modifiers
    }
}
