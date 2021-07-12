//
//  ShowLoaderProtocol.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/19/21.
// 

import UIKit

protocol ShowLoaderProtocol {
    func showLoader(view: UIView) -> UIView
    func hideLoader(loaderView: UIView?)
}

extension ShowLoaderProtocol where Self: UIViewController {
    func showLoader(view: UIView) -> UIView{
        //LoaderView with view size, with indicator placed on center of loaderView
        let loaderView = UIView(frame: view.bounds)
        loaderView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.center = loaderView.center
        loaderView.addSubview(indicator)
        view.addSubview(loaderView)
        indicator.startAnimating()
        loaderView.bringSubviewToFront(view)
        return loaderView
    }
    
    func hideLoader(loaderView: UIView?){
        loaderView?.removeFromSuperview()
    }
}

