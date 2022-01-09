//
//  NetShears.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import UIKit

public final class NetShears: NSObject {
    
    public static let shared = NetShears()
    let networkRequestInterceptor = NetworkRequestInterceptor()

    lazy var config: NetworkInterceptorConfig = {
        var savedModifiers = [RequestEvaluatorModifier]().retrieveFromDisk()
        return NetworkInterceptorConfig(modifiers: savedModifiers)
    }()

    lazy var requestObserver: RequestObserverProtocol = {
        RequestObserver(options: [
            RequestStorage.shared,
            RequestBroadcast.shared
        ])
    }()
    
    
    public func startInterceptor() {
        self.networkRequestInterceptor.startInterceptor()
    }

    public func stopInterceptor() {
        self.networkRequestInterceptor.stopInterceptor()
    }

    public func startLogger() {
        self.networkRequestInterceptor.startLogger()
    }

    public func stopLogger() {
        self.networkRequestInterceptor.stopLogger()
    }

    public func startListener() {
        self.networkRequestInterceptor.startListener()
    }

    public func stopListener() {
        self.networkRequestInterceptor.stopListener()
    }
    
    public func modify(modifier: RequestEvaluatorModifier) {
        config.addModifier(modifier: modifier)
    }
    
    public func modifiedList() -> [RequestEvaluatorModifier] {
        return config.modifiers
    }
    
    public func removeModifier(at index: Int){
        return config.removeModifier(at: index)
    }

    public func presentNetworkMonitor(){
        let storyboard = UIStoryboard.NetShearsStoryBoard
        if let initialVC = storyboard.instantiateInitialViewController(){
            initialVC.modalPresentationStyle = .fullScreen
            UIViewController.currentViewController()?.present(initialVC, animated: true, completion: nil)
        }
    }

    public func addGRPC(url: String,
                        host: String,
                        requestObject: Data?,
                        responseObject: Data?,
                        success: Bool,
                        statusCode: Int,
                        statusMessage: String?,
                        duration: Double?,
                        HPACKHeadersRequest: [String: String]?,
                        HPACKHeadersResponse: [String: String]?){
        let request = NetShearsRequestModel(url: url, host: host, requestObject: requestObject, responseObject: responseObject, success: success, statusCode: statusCode, duration: duration, HPACKHeadersRequest: HPACKHeadersRequest, HPACKHeadersResponse: HPACKHeadersResponse)
        requestObserver.newRequestArrived(request)
    }
}
