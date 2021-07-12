//
//  FileHandler.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 7/8/21.
//

import UIKit

final class FileHandler: NSObject {

    static func writeTxtFile(text: String, path: String){
        FileManager.default.createFile(atPath: path, contents: text.data(using: .utf8, allowLossyConversion: true), attributes: nil)
    }
    
    static func writeTxtFileOnDesktop(text: String, fileName: String){
        let homeUser = NSString(string: "~").expandingTildeInPath.split(separator: "/").dropFirst().first ?? "-"
        let path = "Users/\(homeUser)/Desktop/\(fileName)"
        writeTxtFile(text: text, path: path)
    }
}
