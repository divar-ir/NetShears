//
//  NetworkIgnore.swift
//  
//
//  Created by Mehrdad Goodarzi(Arash) on 6/24/22.
//

import Foundation

public enum Ignore {
    case disbaled
    case enabled(ignoreHandler: (NetShearsRequestModel) -> Bool)
}
