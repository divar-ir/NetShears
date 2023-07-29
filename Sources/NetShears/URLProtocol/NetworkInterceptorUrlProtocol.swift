//
//  NetworkRequestSniffableUrlProtocol.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation

class NetworkInterceptorUrlProtocol: URLProtocol {
    static var blacklistedHosts = [String]()
    
    struct Constants {
        static let RequestHandledKey = "NetworkInterceptorUrlProtocol"
    }
    
    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard NetworkInterceptor.shared.shouldRequestModify(urlRequest: request) else { return false }
        
        if NetworkInterceptorUrlProtocol.property(forKey: Constants.RequestHandledKey, in: request) != nil {
            return actionModifier(forRequest: request) != nil
        }
        return true
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        let mutableRequest: NSMutableURLRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty("YES", forKey: "NetworkInterceptorUrlProtocol", in: mutableRequest)
        return mutableRequest.copy() as! URLRequest
    }
    
    override func startLoading() {
        if let actionModifier = Self.actionModifier(forRequest: request) {
            actionModifier.modify(client: client, urlProtocol: self)
            return
        }
        
        var newRequest = request
        let modifiers = NetShears.shared.config.modifiers.compactMap({ $0 as? RequestEvaluatorModifier })
        for modifier in modifiers where modifier.isActionAllowed(urlRequest: request) {
            modifier.modify(request: &newRequest)
        }
        
        newRequest.addValue("true", forHTTPHeaderField: "Modified")
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
    }
    
    override func stopLoading() {
        sessionTask?.cancel()
        session?.invalidateAndCancel()
    }
    
    deinit {
        session = nil
        sessionTask = nil
    }
    
    class func actionModifier(forRequest request: URLRequest) -> RequestEvaluatorActionModifier? {
        NetShears.shared.config.modifiers
            .compactMap({ $0 as? RequestEvaluatorActionModifier })
            .filter({ $0.isActionAllowed(urlRequest: request) })
            .last
    }
}

extension NetworkInterceptorUrlProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let url = task.currentRequest?.url {
            NetShears.shared.taskProgressDelegate?.task(url, didRecieveProgress: task.progress)
        }
    }
}

