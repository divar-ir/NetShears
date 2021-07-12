//
//  UIView+Extension.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//

import UIKit

extension UIView {
    @discardableResult
    func fillInSuperview(top: CGFloat = 0, trailing: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0) -> Bool {
        guard let superview = superview else {
            return false
        }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom).isActive = true
        leftAnchor.constraint(equalTo: superview.leftAnchor, constant: leading).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -trailing).isActive = true
        return true
    }
}
