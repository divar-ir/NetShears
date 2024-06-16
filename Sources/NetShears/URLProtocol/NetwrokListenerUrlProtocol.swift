//
//  NetwrokListenerUrlProtocol.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import Foundation

class NetwrokListenerUrlProtocol: URLProtocol {
    
    struct Constants {
        static let RequestHandledKey = "NetworkListenerUrlProtocol"
        static let RequestID = "request-id"
    }
    
    var session: URLSession?
    var sessionTasks: ThreadSafeDictionary<String, URLSessionDataTask>?
    var currentRequests: ThreadSafeDictionary<String, NetShearsRequestModel>?

    lazy var requestObserver: RequestObserverProtocol = {
        RequestObserver(options: [
            RequestBroadcast.shared
        ])
    }()

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)

        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        if NetwrokListenerUrlProtocol.property(forKey: Constants.RequestHandledKey, in: request) != nil {
            return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        var newRequest = request
        let id = UUID().uuidString
        newRequest.addValue(id, forHTTPHeaderField: Constants.RequestID)
        return newRequest
    }
    
    override func startLoading() {
        let newRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
        NetwrokListenerUrlProtocol.setProperty(true, forKey: Constants.RequestHandledKey, in: newRequest)
        guard let id = newRequest.value(forHTTPHeaderField: Constants.RequestID) else { return }
        sessionTasks?[id] = session?.dataTask(with: newRequest as URLRequest)
        sessionTasks?[id]?.resume()

        currentRequests?[id] = NetShearsRequestModel(request: newRequest, session: session)
        if let request = currentRequests?[id] {
            requestObserver.newRequestArrived(request)
        }
    }
    
    override func stopLoading() {
        guard let id = request.value(forHTTPHeaderField: Constants.RequestID) else { return }
        sessionTasks?[id]?.cancel()
        currentRequests?[id]?.httpBody = body(from: request)

        if let startDate = currentRequests?[id]?.date {
            currentRequests?[id]?.duration = fabs(startDate.timeIntervalSinceNow) * 1000 //Find elapsed time and convert to milliseconds
        }
        currentRequests?[id]?.isFinished = true

        if let request = currentRequests?[id] {
            requestObserver.newRequestArrived(request)
        }
        session?.invalidateAndCancel()
        sessionTasks?[id] = nil
        currentRequests?[id] = nil
    }
    
    private func body(from request: URLRequest) -> Data? {
        /// The receiver will have either an HTTP body or an HTTP body stream only one may be set for a request.
        /// A HTTP body stream is preserved when copying an NSURLRequest object,
        /// but is lost when a request is archived using the NSCoding protocol.
        return request.httpBody ?? request.getHttpBodyStreamData()
    }
    
    deinit {
        session = nil
        sessionTasks = nil
        currentRequests = nil
    }
}

extension NetwrokListenerUrlProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        guard let id = request.value(forHTTPHeaderField: Constants.RequestID) else { return }
        let currentRequest = currentRequests?[id]

        if currentRequest?.dataResponse == nil {
            currentRequest?.dataResponse = data
        } else {
            currentRequest?.dataResponse?.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let id = request.value(forHTTPHeaderField: Constants.RequestID) else { return }
        let currentRequest = currentRequests?[id]

        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        currentRequest?.initResponse(response: response)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            guard let id = request.value(forHTTPHeaderField: Constants.RequestID) else { return }
            let currentRequest = currentRequests?[id]
            currentRequest?.errorClientDescription = error.localizedDescription
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
        guard let id = request.value(forHTTPHeaderField: Constants.RequestID) else { return }
        let currentRequest = currentRequests?[id]
        currentRequest?.errorClientDescription = error.localizedDescription
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


