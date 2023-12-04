//
//  BookFieldCellViewModel.swift
//  MobileApisAssignment4
//
//  Created by Kosisochukwu Abone on 29/11/23.
//

import UIKit

// Protocol for notifying changes in the field to the cell
protocol BookFieldCellViewModelListener: AnyObject {
    func fieldUpdated(_ field: BookCRUDViewModel.Field, with text: String?)
}

// Protocol defining the requirements for a BookFieldCellViewModel
protocol BookFieldCellViewModelable {
    var field: BookCRUDViewModel.Field { get }
    var detail: String { get }
    func didTypeText(_ text: String?, range: NSRange, newText: String) -> Bool
}

// ViewModel for managing and updating a book field in the UI
final class BookFieldCellViewModel: BookFieldCellViewModelable {
    
    // Book field being managed by this ViewModel
    let field: BookCRUDViewModel.Field
    
    // Current detail (text) of the field
    let detail: String
    
    // Listener for field update events
    private weak var listener: BookFieldCellViewModelListener?
    
    // Initialize the ViewModel with the field, detail, and a listener
    init(field: BookCRUDViewModel.Field, detail: String, listener: BookFieldCellViewModelListener?) {
        self.field = field
        self.detail = detail
        self.listener = listener
    }
    
}

// MARK: - Exposed Helpers
extension BookFieldCellViewModel {
    
    // Called when text is typed or deleted in the associated text field
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
        // Notify the listener about the field update
        listener?.fieldUpdated(field, with: fieldText)
        return true
    }
    
}

// MARK: - BookCRUDViewModel.Field Helpers
extension BookCRUDViewModel.Field {
    
    // Placeholder text for the field
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
    
    // Keyboard type for the field based on the type of data it accepts
    var keyboardType: UIKeyboardType {
        switch self {
        case .name, .author, .genre:
            return .alphabet
        case .rating:
            return .decimalPad
        }
    }
    
    // Determines if the field should become the first responder (for keyboard focus)
    var isFirstResponder: Bool {
        switch self {
        case .name:
            return true
        case .rating, .author, .genre:
            return false
        }
    }
    
}
