//
//  NetShears.swift
//
//
//  Created by Mehdi Mirzaie on 6/4/21.
//

import Foundation


public final class NetShears: NSObject {
    
    public static let shared = NetShears()
    let networkRequestInterceptor = NetworkRequestInterceptor()
    var config: NetworkInterceptorConfig = NetworkInterceptorConfig(modifiers: [])
    
    
    public func startRecording(){
        self.networkRequestInterceptor.startRecording()
    }
    
    public func stopRecording(){
        self.networkRequestInterceptor.stopRecording()
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
}
