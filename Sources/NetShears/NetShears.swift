//
//  NetShears.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import UIKit
import SwiftUI

public protocol BodyExporterDelegate: AnyObject {
    func netShears(exportResponseBodyFor request: NetShearsRequestModel) -> BodyExportType
    func netShears(exportRequestBodyFor request: NetShearsRequestModel) -> BodyExportType
}

public extension BodyExporterDelegate {
    func netShears(exportResponseBodyFor request: NetShearsRequestModel) -> BodyExportType { .default }
    func netShears(exportRequestBodyFor request: NetShearsRequestModel) -> BodyExportType { .default }
}

public final class NetShears: NSObject {
    
    public static let shared = NetShears()
    public weak var bodyExportDelegate: BodyExporterDelegate?
    internal var loggerEnable = false
    internal var interceptorEnable = false
    internal var listenerEnable = false
    internal var swizzled = false
    let networkRequestInterceptor = NetworkRequestInterceptor()

    public var ignore: Ignore = .disbaled

    lazy var config: NetworkInterceptorConfig = {
        var savedModifiers = [Modifier]().retrieveFromDisk()
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
    
    public func modify(modifier: Modifier) {
        config.addModifier(modifier: modifier)
    }
    
    public func modifiedList() -> [Modifier] {
        return config.modifiers
    }
    
    public func removeModifier(at index: Int){
        return config.removeModifier(at: index)
    }

    public func presentNetworkMonitor() {
        let storyboard = UIStoryboard.NetShearsStoryBoard
        if let initialVC = storyboard.instantiateInitialViewController(){
            initialVC.modalPresentationStyle = .fullScreen
            ((initialVC as? UINavigationController)?.topViewController as? RequestsViewController)?.delegate = bodyExportDelegate
            UIViewController.currentViewController()?.present(initialVC, animated: true, completion: nil)
        }
    }
    
    @available(iOS 13.0, *)
    public func view() -> some View {
        NetshearsFlowView()
    }

    public func addGRPC(url: String,
                        host: String,
                        method: String,
                        requestObject: Data?,
                        responseObject: Data?,
                        success: Bool,
                        statusCode: Int,
                        statusMessage: String?,
                        duration: Double?,
                        HPACKHeadersRequest: [String: String]?,
                        HPACKHeadersResponse: [String: String]?){
        let request = NetShearsRequestModel(url: url, host: host, method: method, requestObject: requestObject, responseObject: responseObject, success: success, statusCode: statusCode, duration: duration, HPACKHeadersRequest: HPACKHeadersRequest, HPACKHeadersResponse: HPACKHeadersResponse, isFinished: true)
        if loggerEnable {
            RequestStorage.shared.newRequestArrived(request)
        }
        if listenerEnable {
            RequestBroadcast.shared.newRequestArrived(request)
        }
    }
}
