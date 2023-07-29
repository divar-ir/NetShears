//
//  NetshearsFlowView.swift
//  
//
//  Created by Sam Rayatnia on 09.02.23.
//

import SwiftUI

@available(iOS 13.0, *)
public struct NetshearsFlowView: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard.NetShearsStoryBoard
        guard let initialVC = storyboard.instantiateInitialViewController() else { preconditionFailure() }
        ((initialVC as? UINavigationController)?.topViewController as? RequestsViewController)?.delegate = NetShears.shared.bodyExportDelegate
        return initialVC
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    
}
