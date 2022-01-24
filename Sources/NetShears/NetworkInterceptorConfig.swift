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

public struct HTTPResponseModifyModel: Codable, Equatable {
    public let url: String
    public let httpMethod: String
    
    public let statusCode: Int
    public let data: Data
    public let httpVersion: String?
    public let headers: [String: String]
    
    public init(
        url: String,
        data: Data,
        httpMethod: String = "GET",
        statusCode: Int = 200,
        httpVersion: String? = nil,
        headers: [String : String] = [:]
    ) {
        self.url = url
        self.data = data
        self.httpMethod = httpMethod
        self.statusCode = statusCode
        self.httpVersion = httpVersion
        self.headers = headers
    }
    
    public var response: URLResponse? {
        guard let url = URL(string: url) else { return nil }
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: httpVersion, headerFields: headers)
    }
}

final class NetworkInterceptorConfig {
    var modifiers: [Modifier] = [] {
        didSet {
            modifiers.store()
        }
    }
    
    init(modifiers: [Modifier] = []) {
        self.modifiers = modifiers
    }
    
    func addModifier(modifier: Modifier) {
        self.modifiers.append(modifier)
    }
    
    func getModifiers() -> [Modifier] {
        return self.modifiers
    }
    
    func removeModifier(at index: Int) {
        guard index <= modifiers.count - 1 else { return }
        modifiers.remove(at: index)
    }

}


