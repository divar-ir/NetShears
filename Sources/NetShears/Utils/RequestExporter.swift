//
//  RequestExporter.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import UIKit

public enum BodyExportType {
    case `default`
    case custom(_ text: String)
}

final class RequestExporter: NSObject {
    
    static func overview(request: NetShearsRequestModel) -> NSMutableAttributedString{
        let url = NSMutableAttributedString().bold("URL ").normal(request.url + "\n")
        let method = NSMutableAttributedString().bold("Method ").normal(request.method + "\n")
        let responseCode = NSMutableAttributedString().bold("Response Code ").normal((request.code != 0 ? "\(request.code)" : "-") + "\n")
        let requestStartTime = NSMutableAttributedString().bold("Request Start Time ").normal((request.date.stringWithFormat(dateFormat: "MMM d yyyy - HH:mm:ss") ?? "-") + "\n")
        let duration = NSMutableAttributedString().bold("Duration ").normal(request.duration?.formattedMilliseconds() ?? "-" + "\n")
        let final = NSMutableAttributedString()
        for attr in [url, method, responseCode, requestStartTime, duration]{
            final.append(attr)
        }
        return final
    }
    
    static func header(_ headers: [String: String]?) -> NSMutableAttributedString{
        guard let headerDictionary = headers else {
            return NSMutableAttributedString(string: "-")
        }
        let final = NSMutableAttributedString()
        for (key, value) in headerDictionary {
            final.append(NSMutableAttributedString().bold(key).normal(" " + value + "\n"))
        }
        return final
    }
    
    static func body(_ body: Data?, splitLength: Int? = nil, bodyExportType: BodyExportType, completion: @escaping (String) -> Void){
        DispatchQueue.global().async {
            completion(RequestExporter.body(body, splitLength: splitLength, bodyExportType: bodyExportType))
            return
        }
    }
    
    static func body(_ body: Data?, splitLength: Int? = nil, bodyExportType: BodyExportType) -> String {
        if case .custom(let text) = bodyExportType {
            return text
        }
        
        guard body != nil else {
            return "-"
        }
        
        if let data = splitLength != nil ? String(data: body!, encoding: .utf8)?.characters(n: splitLength!) : String(data: body!, encoding: .utf8){
            return data.prettyPrintedJSON ?? data
        }
        
        return "-"
    }
    
    static func txtExport(request: NetShearsRequestModel, delegate: BodyExporterDelegate?) -> String{
        
        var txt: String = ""
        txt.append("*** Overview *** \n")
        txt.append(overview(request: request).string + "\n\n")
        txt.append("*** Request Header *** \n")
        txt.append(header(request.headers).string + "\n\n")
        txt.append("*** Request Body *** \n")
        txt.append(body(request.httpBody, bodyExportType: delegate?.netShears(exportRequestBodyFor: request) ?? .default) + "\n\n")
        txt.append("*** Response Header *** \n")
        txt.append(header(request.responseHeaders).string + "\n\n")
        txt.append("*** Response Body *** \n")
        txt.append(body(request.dataResponse, bodyExportType: delegate?.netShears(exportResponseBodyFor: request) ?? .default) + "\n\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n\n\n\n")
        return txt
    }
    
    static func curlExport(request: NetShearsRequestModel, delegate: BodyExporterDelegate?) -> String{
        
        var txt: String = ""
        txt.append("*** Overview *** \n")
        txt.append(overview(request: request).string + "\n\n")
        txt.append("*** curl Request *** \n")
        txt.append(request.curlRequest + "\n\n")
        txt.append("*** Response Header *** \n")
        txt.append(header(request.responseHeaders).string + "\n\n")
        txt.append("*** Response Body *** \n")
        txt.append(body(request.dataResponse, bodyExportType: delegate?.netShears(exportResponseBodyFor: request) ?? .default) + "\n\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n\n\n\n")
        return txt
    }
}

