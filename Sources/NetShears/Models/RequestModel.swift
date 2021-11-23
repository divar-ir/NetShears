//
//  RequestModel.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//
import Foundation
import UIKit

public final class NetShearsRequestModel: Codable {
    let id: String
    let url: String
    let host: String?
    let port: Int?
    let scheme: String?
    let date: Date
    let method: String
    let headers: [String: String]
    var credentials: [String : String]
    var cookies: String?
    var httpBody: Data?
    var code: Int
    var responseHeaders: [String: String]?
    var dataResponse: Data?
    var errorClientDescription: String?
    var duration: Double?
    
    init(request: NSURLRequest, session: URLSession?) {
        id = UUID().uuidString
        url = request.url?.absoluteString ?? ""
        host = request.url?.host
        port = request.url?.port
        scheme = request.url?.scheme
        date = Date()
        method = request.httpMethod ?? "GET"
        credentials = [:]
        var headers = request.allHTTPHeaderFields ?? [:]
        httpBody = request.httpBody
        code = 0
        
        
        // collect all HTTP Request headers except the "Cookie" header. Many request representations treat cookies with special parameters or structures. For cookie collection, refer to the bottom part of this method
        session?.configuration.httpAdditionalHeaders?
            .filter {  $0.0 != AnyHashable("Cookie") }
            .forEach { element in
                guard let key = element.0 as? String, let value = element.1 as? String else { return }
                headers[key] = value
        }
        self.headers = headers
        
        // if the target server uses HTTP Basic Authentication, collect username and password
        if let credentialStorage = session?.configuration.urlCredentialStorage,
            let host = self.host,
            let port = self.port {
            let protectionSpace = URLProtectionSpace(
                host: host,
                port: port,
                protocol: scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )

            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    guard let user = credential.user, let password = credential.password else { continue }
                    self.credentials[user] = password
                }
            }
        }
        
        //  collect cookies associated with the target host
        //  TODO: Add the else branch.
        /*  With the condition below, it is handled only the case where session.configuration.httpShouldSetCookies == true.
            Some developers could opt to handle cookie manually using the "Cookie" header stored in httpAdditionalHeaders
            and disabling the handling provided by URLSessionConfiguration (httpShouldSetCookies == false).
            See: https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1411589-httpshouldsetcookies?language=objc
        */
        if let session = session, let url = request.url, session.configuration.httpShouldSetCookies {
            if let cookieStorage = session.configuration.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty {
                self.cookies = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
            }
        }
    }
    
    func initResponse(response: URLResponse) {
        guard let responseHttp = response as? HTTPURLResponse else {return}
        code = responseHttp.statusCode
        responseHeaders = responseHttp.allHeaderFields as? [String: String]
    }
    
    init(url: String,
         host: String,
         requestObject: Data?,
         responseObject: Data?,
         success: Bool,
         statusCode: Int,
         duration: Double?,
         HPACKHeadersRequest: [String: String]?,
         HPACKHeadersResponse: [String: String]?) {
        self.id = UUID().uuidString
        self.method = "gRPC"
        self.scheme = "gRPC"
        self.url = url
        self.host = host
        self.httpBody = requestObject
        self.code = statusCode
        self.responseHeaders = HPACKHeadersResponse
        self.headers = HPACKHeadersRequest ?? [:]
        self.dataResponse = responseObject
        self.date = Date()
        self.port = nil
        self.duration = duration
        self.credentials = [:]
    }
    
    var curlRequest: String {
        var components = ["$ curl -v"]

        guard
            let _ = self.host
        else {
            return "$ curl command could not be created"
        }

        if method != "GET" {
            components.append("-X \(method)")
        }
        
        components += headers.map {
            let escapedValue = String(describing: $0.value).replacingOccurrences(of: "\"", with: "\\\"")
            return "-H \"\($0.key): \(escapedValue)\""
        }

        if let httpBodyData = httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            // the following replacingOccurrences handles cases where httpBody already contains the escape \ character before the double quotation mark (") character
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"") // \" -> \\\"
            // the following replacingOccurrences escapes the character double quotation mark (")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"") // " -> \"

            components.append("-d \"\(escapedBody)\"")
        }
        
        for credential in credentials {
            components.append("-u \(credential.0):\(credential.1)")
        }
        
        if let cookies = cookies {
            components.append("-b \"\(cookies[..<cookies.index(before: cookies.endIndex)])\"")
        }

        components.append("\"\(url)\"")

        return components.joined(separator: " \\\n\t")
    }
    
    var postmanItem: PMItem? {
        guard
            let url = URL(string: self.url),
            let scheme = self.scheme,
            let host = self.host
            else { return nil }
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd_HHmmss"
        
        let name = "\(dateFormatterGet.string(from: date))-\(url)"
        
        var headers: [PMHeader] = []
        let method = self.method
        for header in self.headers {
            headers.append(PMHeader(key: header.0, value: header.1))
        }
        
        var rawBody: String = ""
        if let httpBodyData = httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            rawBody = httpBody
        }
        
        let hostList = host.split(separator: ".")
            .map{ String(describing: $0) }
        
        var pathList = url.pathComponents
        pathList.removeFirst()

        let body = PMBody(mode: "raw", raw: rawBody)
        
        let query: [PMQuery]? = url.query?.split(separator: "&").compactMap{ element in
            let splittedElements = element.split(separator: "=")
            guard splittedElements.count == 2 else { return nil }
            let key = String(splittedElements[0])
            let value = String(splittedElements[1])
            return PMQuery(key: key, value: value)
        }

        let urlPostman = PMURL(raw: url.absoluteString, urlProtocol: scheme, host: hostList, path: pathList, query: query)
        let request = PMRequest(method: method, header: headers, body: body, url: urlPostman, description: "")
        
        // build response
        
        let responseHeaders = self.responseHeaders?.compactMap{ (key, value) in
            return PMHeader(key: key, value: value)
        } ?? []
        
        let responseBody: String
        if let data = dataResponse, let string = String(data: data, encoding: .utf8) {
            responseBody = string
        }
        else {
            responseBody = ""
        }
        
        let response = PMResponse(name: url.absoluteString, originalRequest: request, status: "", code: code, postmanPreviewlanguage: "html", header: responseHeaders, cookie: [], body: responseBody)
        
        return PMItem(name: name, item: nil, request: request, response: [response])
    }
}
