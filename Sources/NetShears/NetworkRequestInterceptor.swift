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
        URLProtocol.registerClass(NetworkInterceptorUrlProtocol.self)
    }

    func stopInterceptor() {
        URLProtocol.unregisterClass(NetworkInterceptorUrlProtocol.self)
        swizzleProtocolClasses()
    }

    func startLogger() {
        URLProtocol.registerClass(NetworkLoggerUrlProtocol.self)
        swizzleProtocolClasses()
    }

    func stopLogger() {
        URLProtocol.unregisterClass(NetworkLoggerUrlProtocol.self)
        swizzleProtocolClasses()
    }

    func startListener() {
        URLProtocol.registerClass(NetwrokListenerUrlProtocol.self)
        swizzleProtocolClasses()
    }

    func stopListener() {
        URLProtocol.unregisterClass(NetwrokListenerUrlProtocol.self)
        swizzleProtocolClasses()
    }
}


