//
//  File.swift
//  
//
//  Created by Mehrdad Goodarzi(Arash) on 6/24/22.
//

import Foundation

public enum Ignore {
    case disbaled
    case enabled(ignoreHandler: (URLRequest) -> Bool, onFeatures: [IgnoringFeature])

    static func shouldIgnore(request: URLRequest, on feature: IgnoringFeature) -> Bool {
        guard case let Ignore.enabled(ignoreHandler,ignoringFeatures) = NetShears.shared.ignore else {
            return false
        }
        guard ignoringFeatures.contains(feature) else {
            return false
        }
        return ignoreHandler(request)
    }
}

public enum IgnoringFeature {
    case interceptor
    case logger
    case listener
}

/*
func example() {
    NetShears.shared.ignore = .enabled(
        ignoreHandler: { request in
            let shouldIgnore = ...
            return shouldIgnore
        },
        onFeatures: [.listener])
}
*/
