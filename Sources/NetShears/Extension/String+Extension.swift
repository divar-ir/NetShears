//
//  String+Extension.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import Foundation

extension String {
    //substrings of equal length
    func characters(n: Int) -> String{
        return String(prefix(n))
    }
    
    var prettyPrintedJSON: String? {
        guard let stringData = self.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: stringData, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let formattedJSON = String(data: jsonData, encoding: .utf8) else { return nil }

        return formattedJSON.replacingOccurrences(of: "\\/", with: "/")
    }
}
