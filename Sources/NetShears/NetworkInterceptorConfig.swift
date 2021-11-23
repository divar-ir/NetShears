//
//  NetworkInterceptorConfig.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation

struct RedirectedRequestModel: Codable, Equatable {
    let originalUrl: String
    let redirectUrl: String

    init (originalUrl: String, redirectUrl: String) {
        self.originalUrl = originalUrl
        self.redirectUrl = redirectUrl
    }
}

struct HeaderModifyModel: Codable, Equatable {
    let key: String
    let value: String

    init (key: String, value: String) {
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


