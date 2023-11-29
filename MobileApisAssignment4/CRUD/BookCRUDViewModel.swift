//
//  BookCRUDViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 27/11/23.
//

import Foundation

protocol BookCRUDViewModelable {
    var title: String { get }
    func screenDidLoad()
}

final class BookCRUDViewModel: BookCRUDViewModelable {
    
    enum Field {
        case name
        case rating
        case author
        case genre
    }
    
    private let book: Book?
    
    init(book: Book?) {
        self.book = book
    }
    
}

// MARK: - Exposed Helpers
extension BookCRUDViewModel {
    
    var title: String {
        return book?.name ?? Constants.addBook
    }
    
    func screenDidLoad() {
        // TODO: - Load data from book
    }
    
}
