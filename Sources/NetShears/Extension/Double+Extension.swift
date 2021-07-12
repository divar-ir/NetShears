//
//  Double+Extension.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import Foundation

extension Double {
    func formattedMilliseconds() -> String{
        
        let rounded = self
        if rounded < 1000 {
            return "\(Int(rounded))ms"
        } else if rounded < 1000 * 60 {
            let seconds = rounded / 1000
            return "\(Int(seconds))s"
        } else if rounded < 1000 * 60 * 60 {
            let secondsTemp = rounded / 1000
            let minutes = secondsTemp / 60
            let seconds = (rounded - minutes * 60 * 1000) / 1000
            return "\(Int(minutes))m \(Int(seconds))s"
        } else if self < 1000 * 60 * 60 * 24 {
            let minutesTemp = rounded / 1000 / 60
            let hours = minutesTemp / 60
            let minutes = (rounded - hours * 60 * 60 * 1000) / 1000 / 60
            let seconds = (rounded - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(Int(hours))h \(Int(minutes))m \(Int(seconds))s"
        } else {
            let hoursTemp = rounded / 1000 / 60 / 60
            let days = hoursTemp / 24
            let hours = (rounded - days * 24 * 60 * 60 * 1000) / 1000 / 60 / 60
            let minutes = (rounded - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000) / 1000 / 60
            let seconds = (rounded - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(Int(days))d \(Int(hours))h \(Int(minutes))m \(Int(seconds))s"
        }
    }
}
