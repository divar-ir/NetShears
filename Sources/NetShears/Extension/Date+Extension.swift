//
//  Date+Extension.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 7/4/21.
//

import Foundation

extension Date{
    func stringWithFormat(dateFormat: String, timezone: TimeZone? = nil) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if timezone != nil{
            dateFormatter.timeZone = timezone!
        }
        return dateFormatter.string(from: self)
    }
}

