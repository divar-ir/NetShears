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


extension Bundle {
    static var NetShearsBundle: Bundle {
        let podBundle = Bundle(for: NetShears.classForCoder())
        if let bundleURL = podBundle.url(forResource: "NetShears", withExtension: "bundle"){
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        
        return Bundle(for: NetShears.classForCoder())
    }
}
