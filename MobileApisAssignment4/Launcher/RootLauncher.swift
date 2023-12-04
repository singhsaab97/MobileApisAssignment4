//
//  RootLauncher.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

// RootLauncher class is responsible for launching the root view controller of the application.
final class RootLauncher {
    
    // The window where the root view controller will be displayed.
    private let window: UIWindow?
    
    // Initializes the RootLauncher with a UIWindow and sets up the necessary configurations.
    init(window: UIWindow?) {
        self.window = window
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension RootLauncher {
    
    // Launches the application, determining whether to show the authentication screen or the BooksViewController.
    func launch() {
        guard let authToken = UserDefaults.appSuite.string(forKey: UserDefaults.authTokenKey) else {
            showAuthenticationScreen()
            return
        }
        
        // If authentication token exists, initialize BooksViewController with appropriate configurations.
        let viewController = BooksViewController.loadFromStoryboard()
        let viewModel = BooksViewModel(authToken: authToken, listener: self)
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        
        // Embed BooksViewController in a navigation controller and set it as the root view controller.
        let navigationController = viewController.embeddedInNavigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.isTranslucent = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
}

// MARK: - Private Helpers
private extension RootLauncher {
    
    // Sets up the appearance of navigation bar, button, and text field for the entire application.
    func setup() {
        UINavigationBar.appearance().tintColor = .systemIndigo
        UIButton.appearance().tintColor = .systemIndigo
        UITextField.appearance().tintColor = .systemIndigo
    }
    
    // Displays the authentication screen when there is no authentication token.
    func showAuthenticationScreen() {
        let viewController = AuthenticationViewController.loadFromStoryboard()
        let viewModel = AuthenticationViewModel(flow: .signIn)
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        
        // Set authentication screen as the root view controller.
        window?.rootViewController = viewController.embeddedInNavigationController
        window?.makeKeyAndVisible()
    }
    
}

// MARK: - BooksViewModelListener Methods
extension RootLauncher: BooksViewModelListener {
    
    // Handles the user logging out event by removing the authentication token and showing the authentication screen.
    func userLoggingOut() {
        UserDefaults.appSuite.removeObject(forKey: UserDefaults.authTokenKey)
        showAuthenticationScreen()
    }
    
}
