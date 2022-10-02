//
//  File.swift
//  
//
//  Created by Arash on 9/14/22.
//

import UIKit
import SafariServices

struct JSONValidatorOnline {

    func open(jsonString: String?, on vc: UIViewController) {
        guard let jsonString = jsonString,
              let encodedJson = jsonString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        else {
            print("NetShears - jsonString not received")
            return
        }
        let base = "https://jsoneditoronline.org/#left=json."
        let mode = "&mode=tree"
        let url = base + encodedJson + mode
        openBrowser(for: url, on: vc)
    }

    private func openBrowser(for url: String, on vc: UIViewController) {
        guard #available(iOS 11.0, *) else {
            print("NetShears - iOS version not supported")
            return
        }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        guard let url = URL(string: url) else {
            print("NetShears - invalid url")
            return
        }
        let browserVc = SFSafariViewController(url: url, configuration: config)
        vc.present(browserVc, animated: true)
    }
}
