//
//  NetworkInterceptorConfig.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation

public struct RedirectedRequestModel: Codable, Equatable {
    public let originalUrl: String
    public let redirectUrl: String

    public init(originalUrl: String, redirectUrl: String) {
        self.originalUrl = originalUrl
        self.redirectUrl = redirectUrl
    }
}

public struct HeaderModifyModel: Codable, Equatable {
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

final class NetworkInterceptorConfig {
    var modifiers: [RequestEvaluatorModifier] = [] {
        didSet {
            modifiers.store()
        }
    }
    
    init(modifiers: [RequestEvaluatorModifier] = []) {
        self.modifiers = modifiers
    }
    
    func addModifier(modifier: RequestEvaluatorModifier) {
        self.modifiers.append(modifier)
    }
    
    func getModifiers() -> [RequestEvaluatorModifier] {
        return self.modifiers
    }
    
    func removeModifier(at index: Int) {
        guard index <= modifiers.count - 1 else { return }
        modifiers.remove(at: index)
    }

}


