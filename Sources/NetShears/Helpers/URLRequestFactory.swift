//
//  URLRequestFactory.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation

extension URLRequest {
    mutating func modifyURLRequestEndpoint(redirectUrl: RedirectedRequestModel) {
        var urlString = "\(url!.absoluteString)"
        urlString = urlString.replacingOccurrences(of: redirectUrl.originalUrl, with: redirectUrl.redirectUrl)
        url = URL(string: urlString)!
    }
    
    mutating func modifyURLRequestHeader(header: HeaderModifyModel) {
        setValue(header.value, forHTTPHeaderField: header.key)
    }
}

