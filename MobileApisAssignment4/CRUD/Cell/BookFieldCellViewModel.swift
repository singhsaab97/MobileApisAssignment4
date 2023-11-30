//
//  BookFieldCellViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 29/11/23.
//

import UIKit

protocol BookFieldCellViewModelListener: AnyObject {
    func fieldUpdated(_ field: BookCRUDViewModel.Field, with text: String?)
}

protocol BookFieldCellViewModelable {
    var field: BookCRUDViewModel.Field { get }
    var detail: String { get }
    func didTypeText(_ text: String?, range: NSRange, newText: String) -> Bool
}

final class BookFieldCellViewModel: BookFieldCellViewModelable {
    
    let field: BookCRUDViewModel.Field
    let detail: String
    
    private weak var listener: BookFieldCellViewModelListener?
        
    init(field: BookCRUDViewModel.Field, detail: String, listener: BookFieldCellViewModelListener?) {
        self.field = field
        self.detail = detail
        self.listener = listener
    }
    
}

// MARK: - Exposed Helpers
extension BookFieldCellViewModel {
    
    func didTypeText(_ text: String?, range: NSRange, newText: String) -> Bool {
        guard let text = text else { return false }
        var fieldText: String?
        if newText.isEmpty {
            // Deleting
            fieldText = range.length > 1
                ? String()
                : text.count <= 1 ? String() : String(text.dropLast())
        } else {
            // Typing
            fieldText = text.appending(newText)
        }
        listener?.fieldUpdated(field, with: fieldText)
        return true
    }
    
}

// MARK: - BookCRUDViewModel.Field Helpers
extension BookCRUDViewModel.Field {
    
    var placeholder: String {
        switch self {
        case .name:
            return Constants.nameFieldPlaceholder
        case .rating:
            return Constants.ratingFieldPlaceholder
        case .author:
            return Constants.authorFieldPlaceholder
        case .genre:
            return Constants.genreFieldPlaceholder
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .name, .author, .genre:
            return .alphabet
        case .rating:
            return .decimalPad
        }
    }
    
    var isFirstResponder: Bool {
        switch self {
        case .name:
            return true
        case .rating, .author, .genre:
            return false
        }
    }
    
}
