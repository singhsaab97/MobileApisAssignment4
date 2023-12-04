//
//  BookFieldTableViewCell.swift
//  MobileApisAssignment4
//
//  Created by Kosisochukwu Abone on 29/11/23.
//

import UIKit

// Custom UITableViewCell for displaying and editing book details
final class BookFieldTableViewCell: UITableViewCell, ViewLoadable {
    
    // Constants for the cell name and identifier
    static let name = Constants.bookFieldCell
    static let identifier = Constants.bookFieldCell
    
    // Outlet for the detail text field
    @IBOutlet private weak var detailTextField: UITextField!
    
    // ViewModel associated with the cell
    private var viewModel: BookFieldCellViewModelable?
    
    // Called when the cell is awakened from a nib or storyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension BookFieldTableViewCell {
    
    // Configures the cell with the provided viewModel
    func configure(with viewModel: BookFieldCellViewModelable) {
        self.viewModel = viewModel
        
        // Set attributed placeholder for the text field
        detailTextField.attributedPlaceholder = NSAttributedString(
            string: viewModel.field.placeholder,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: Constants.placeholderFont
            ]
        )
        
        // Set keyboard type, text, and first responder status
        detailTextField.keyboardType = viewModel.field.keyboardType
        detailTextField.text = viewModel.detail
        
        // Handle first responder status
        _ = viewModel.field.isFirstResponder
        ? detailTextField.becomeFirstResponder()
        : detailTextField.resignFirstResponder()
    }
    
}

// MARK: - Private Helpers
private extension BookFieldTableViewCell {
    
    // Setup cell appearance and behavior
    func setup() {
        selectionStyle = .none
        detailTextField.borderStyle = .none
        detailTextField.delegate = self
    }
    
}

// MARK: - UITextFieldDelegate Methods
extension BookFieldTableViewCell: UITextFieldDelegate {
    
    // Called before a change is made to the text field's contents
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewModel?.didTypeText(textField.text, range: range, newText: string) ?? false
    }
    
}
