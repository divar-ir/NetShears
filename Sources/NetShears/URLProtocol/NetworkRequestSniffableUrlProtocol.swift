//
//  NetworkRequestSniffableUrlProtocol.swift
//
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation

public class NetworkRequestSniffableUrlProtocol: URLProtocol {
    static var blacklistedHosts = [String]()

    struct Constants {
        static let RequestHandledKey = "NetworkRequestSniffableUrlProtocol"
    }
    
    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    override public class func canInit(with request: URLRequest) -> Bool {
        guard NetworkInterceptor.shared.shouldRequestModify(urlRequest: request) else { return false }

        if NetworkRequestSniffableUrlProtocol.property(forKey: Constants.RequestHandledKey, in: request) != nil {
            return false
        }
        return true
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        let mutableRequest: NSMutableURLRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty("YES", forKey: "NetworkRequestSniffableUrlProtocol", in: mutableRequest)
        return mutableRequest.copy() as! URLRequest
    }
    
    override public func startLoading() {
        var newRequest = request
        for modifier in NetShears.shared.config.modifiers where modifier.isActionAllowed(urlRequest: request) {
            modifier.modify(request: &newRequest)
        }
        
        newRequest.addValue("true", forHTTPHeaderField: "Modified")
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
    }
    
    override public func stopLoading() {
        sessionTask?.cancel()
        session?.invalidateAndCancel()
    }
    
    deinit {
        session = nil
        sessionTask = nil
    }
}

extension NetworkRequestSniffableUrlProtocol: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        let sender = challenge.sender
        
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
                return
            }
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}

