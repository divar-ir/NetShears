//
//  NSNavigationController.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import UIKit

final class NSNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customiseApperance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func customiseApperance() {
        //Large titles
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
        }
        
        // Appearance
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            navBarAppearance.backgroundColor = UIColor.systemBackground
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationBar.tintColor = .systemBlue
        }
    }
    
}
