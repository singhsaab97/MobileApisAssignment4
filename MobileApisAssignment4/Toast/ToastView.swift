//
//  ToastView.swift
//  MobileApisAssignment4
//
//  Created by Ilham Sheikh on 15/11/23.
//

import UIKit

final class ToastView: UIView,
                       ViewLoadable {
    
    static var name = Constants.toastView
    static var identifier = Constants.toastView
    
    @IBOutlet private weak var messageLabel: UILabel!

}

// MARK: - Exposed Helpers
extension ToastView {
    
    func setMessage(_ message: String) {
        messageLabel.text = message
    }
   
}
