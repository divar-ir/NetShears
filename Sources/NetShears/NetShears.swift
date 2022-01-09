//
//  NetShears.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import UIKit

public final class NetShears: NSObject {
    
    public static let shared = NetShears()
    internal var loggerEnable = false
    internal var interceptorEnable = false
    internal var listenerEnable = false
    internal var swizzled = false
    let networkRequestInterceptor = NetworkRequestInterceptor()

    lazy var config: NetworkInterceptorConfig = {
        var savedModifiers = [RequestEvaluatorModifier]().retrieveFromDisk()
        return NetworkInterceptorConfig(modifiers: savedModifiers)
    }()

    private func checkSwizzling() {
        if swizzled == false {
            self.networkRequestInterceptor.swizzleProtocolClasses()
            swizzled = true
        }
    }
    public func startInterceptor() {
        self.networkRequestInterceptor.startInterceptor()
        checkSwizzling()
    }

    public func stopInterceptor() {
        self.networkRequestInterceptor.stopInterceptor()
        checkSwizzling()
    }

    public func startLogger() {
        self.networkRequestInterceptor.startLogger()
        checkSwizzling()
    }

    public func stopLogger() {
        self.networkRequestInterceptor.stopLogger()
        checkSwizzling()
    }

    public func startListener() {
        self.networkRequestInterceptor.startListener()
        checkSwizzling()
    }

    public func stopListener() {
        self.networkRequestInterceptor.stopListener()
        checkSwizzling()
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
        if loggerEnable {
            RequestStorage.shared.newRequestArrived(request)
        }
        if listenerEnable {
            RequestBroadcast.shared.newRequestArrived(request)
        }
    }
}
