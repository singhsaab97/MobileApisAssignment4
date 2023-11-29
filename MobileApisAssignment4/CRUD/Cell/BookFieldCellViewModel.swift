//
//  BookFieldCellViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 29/11/23.
//

import UIKit

protocol BookFieldCellViewModelable {
    var field: BookCRUDViewModel.Field { get }
    var detail: String { get }
}

final class BookFieldCellViewModel: BookFieldCellViewModelable {
    
    let field: BookCRUDViewModel.Field
    let detail: String
    
    init(field: BookCRUDViewModel.Field, detail: String) {
        self.field = field
        self.detail = detail
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
