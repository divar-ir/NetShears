//
//  NetShearsModfierProtocol.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/19/21.
//

import Foundation

public protocol Modifier: RequestEvaluator, RequestModifierStorage, Codable {}

public protocol RequestEvaluator {
    func isActionAllowed(urlRequest: URLRequest) -> Bool
}

public protocol RequestModifier: Modifier {
    func modify(request: inout URLRequest)
}

public protocol RequestActionModifier: Modifier {
    func modify(client: URLProtocolClient?, urlProtocol: URLProtocol)
}

public protocol RequestModifierStorage {
    static var storeFileName: String { get }
}

public typealias RequestEvaluatorModifier = Modifier & RequestEvaluator & RequestModifier & RequestModifierStorage & Codable

public typealias RequestEvaluatorActionModifier = Modifier & RequestEvaluator & RequestActionModifier & RequestModifierStorage & Codable

extension RequestModifierStorage where Self: Modifier {
    static func store(_ array: [Codable]) {
        PersistHelper.store(array.compactMap({ $0 as? Self }), as: Self.storeFileName)
    }
    
    static func retrieveFromDisk() -> [Self] {
        PersistHelper.retrieve(Self.storeFileName, as: [Self].self) ?? []
    }
}

extension Array where Element == Modifier {
    func store() {
        RequestEvaluatorModifierHeader.store(self)
        RequestEvaluatorModifierEndpoint.store(self)
        RequestEvaluatorModifierResponse.store(self)
    }
    
    func retrieveFromDisk() -> [Modifier] {
        var modifiers = [Modifier]()
        modifiers.append(contentsOf: RequestEvaluatorModifierHeader.retrieveFromDisk())
        modifiers.append(contentsOf: RequestEvaluatorModifierEndpoint.retrieveFromDisk())
        modifiers.append(contentsOf: RequestEvaluatorModifierResponse.retrieveFromDisk())
        return modifiers
    }
}
