//
//  Section.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import UIKit

struct NetShearsSection {
    var name: String
    var type: SectionType
    
    init(name: String, type: SectionType) {
        self.name = name
        self.type = type
    }
}

enum SectionType {
    case overview
    case requestHeader
    case requestBody
    case responseHeader
    case responseBody
}
