//
//  NetworkRequestInterceptor.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/4/21.
//
import Foundation


@objc class NetworkRequestInterceptor: NSObject{
    
    func swizzleProtocolClasses(){
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!
        
        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.fakeProcotolClasses))!
        
        method_exchangeImplementations(method1, method2)
    }

    func startInterceptor() {
        NetShears.shared.interceptorEnable = true
        URLProtocol.registerClass(NetworkInterceptorUrlProtocol.self)
    }

    func stopInterceptor() {
        NetShears.shared.interceptorEnable = false
        URLProtocol.unregisterClass(NetworkInterceptorUrlProtocol.self)
    }

    func startLogger() {
        NetShears.shared.loggerEnable = true
        URLProtocol.registerClass(NetworkLoggerUrlProtocol.self)
    }

    func stopLogger() {
        NetShears.shared.loggerEnable = false
        URLProtocol.unregisterClass(NetworkLoggerUrlProtocol.self)
    }

    func startListener() {
        NetShears.shared.listenerEnable = true
        URLProtocol.registerClass(NetwrokListenerUrlProtocol.self)
    }

    func stopListener() {
        NetShears.shared.listenerEnable = false
        URLProtocol.unregisterClass(NetwrokListenerUrlProtocol.self)
    }
}


