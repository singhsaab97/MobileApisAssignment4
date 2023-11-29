//
//  BookFieldTableViewCell.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 29/11/23.
//

import UIKit

final class BookFieldTableViewCell: UITableViewCell,
                                    ViewLoadable {
    
    static let name = Constants.bookFieldCell
    static let identifier = Constants.bookFieldCell
    
    @IBOutlet private weak var detailTextField: UITextField!
    
    private var viewModel: BookFieldCellViewModelable?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

}

// MARK: - Exposed Helpers
extension BookFieldTableViewCell {
    
    func configure(with viewModel: BookFieldCellViewModelable) {
        self.viewModel = viewModel
        detailTextField.attributedPlaceholder = NSAttributedString(
            string: viewModel.field.placeholder,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: Constants.placeholderFont
            ]
        )
        detailTextField.keyboardType = viewModel.field.keyboardType
        detailTextField.text = viewModel.detail
        _ = viewModel.field.isFirstResponder
            ? detailTextField.becomeFirstResponder()
            : detailTextField.resignFirstResponder()
    }
    
}

// MARK: - Private Helpers
private extension BookFieldTableViewCell {
    
    func setup() {
        detailTextField.borderStyle = .none
        detailTextField.delegate = self
    }
    
}

// MARK: - UITextFieldDelegate Methods
extension BookFieldTableViewCell: UITextFieldDelegate {
    
}
