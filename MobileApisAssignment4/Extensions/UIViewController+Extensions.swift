//
//  UIViewController+Extensions.swift
//  MobileApisAssignment4
//
//  Created by Ilham Sheikh on 15/11/23.
//

import UIKit

extension UIViewController {
    
    var embeddedInNavigationController: UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalPresentationCapturesStatusBarAppearance = true
        return navigationController
    }
    
}
