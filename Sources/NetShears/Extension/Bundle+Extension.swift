//
//  Bundle+Extension.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 7/12/22.
//

import Foundation

extension Bundle {
    static var NetShearsBundle: Bundle {
        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.module
        return resourceBundle
        #else
        let podBundle = Bundle(for: NetShears.classForCoder())
        if let bundleURL = podBundle.url(forResource: "NetShears", withExtension: "bundle"){
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        return Bundle(for: NetShears.classForCoder())
        #endif
    }
}
