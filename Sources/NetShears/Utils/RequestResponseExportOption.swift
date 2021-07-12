//
//  RequestResponseExportOption.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//


import Foundation

/// `RequestResponseExportOption` is the type used to handle different export representations of HTTP requests and responses collected by Wormholy.
enum RequestResponseExportOption {
    /// Export a request and its response in a "human" readable mode.
    case flat
    /// Request is exported as a cURL command; response is exported in a "human" readable mode.
    case curl
    /// Request and response are exported as Postman collection (v.2.1). Response is attached as "example".
    case postman
    
    func filenameSuffix() -> String {
        switch self {
        case .flat, .curl:
            return "-wormholy.txt"
        case .postman:
            return "-postman_collection.json"
        }
    }
}
