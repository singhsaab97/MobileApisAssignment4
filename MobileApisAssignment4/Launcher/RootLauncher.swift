//
//  RootLauncher.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

final class RootLauncher {
    
    private let window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension RootLauncher {
    
    func launch() {
        let viewController = AuthenticationViewController.loadFromStoryboard()
        let viewModel = AuthenticationViewModel(flow: .signIn)
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        window?.rootViewController = viewController.embeddedInNavigationController
        window?.makeKeyAndVisible()
    }
    
}

// MARK: - Private Helpers
private extension RootLauncher {
    
    func setup() {
        UINavigationBar.appearance().tintColor = .systemIndigo
        UIButton.appearance().tintColor = .systemIndigo
        UITextField.appearance().tintColor = .systemIndigo
    }
  
}
