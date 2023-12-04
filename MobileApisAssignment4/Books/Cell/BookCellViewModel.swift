//
//  BookCellViewModel.swift
//  MobileApisAssignment4
//
//  Created by Kosisochukwu Abone on 15/11/23.
//

import Foundation

// Protocol defining requirements for a BookCellViewModel
protocol BookCellViewModelable {
    var book: Book { get }
    var state: BookCellViewModel.RatingState { get }
    var bookRating: String? { get }
    var creationDate: String { get }
}

// Concrete implementation of the BookCellViewModel protocol
final class BookCellViewModel: BookCellViewModelable {
    
    /// Determines the background color of book rating
    enum RatingState {
        case good
        case okay
        case meh
        case bad
        case unknown
    }
    
    // Properties
    let book: Book
    private(set) var state: RatingState
    
    // Date formatters for formatting creation dates
    private lazy var inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.inputCreationDateFormat
        return formatter
    }()
    
    private lazy var outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.outputCreationDateFormat
        return formatter
    }()
    
    // Number formatter for formatting book ratings
    private lazy var ratingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // Initialization
    init(book: Book) {
        self.book = book
        self.state = .unknown
        setRatingState()
    }
    
}

// MARK: - Exposed Helpers
extension BookCellViewModel {
    
    // Formatted book rating as a string
    var bookRating: String? {
        return ratingFormatter.string(from: NSNumber(value: book.rating))
    }
    
    // Formatted creation date as a string
    var creationDate: String {
        guard let dateString = book.creationDate,
              let inputDate = inputDateFormatter.date(from: dateString) else { return String() }
        return outputDateFormatter.string(from: inputDate)
    }
    
}

// MARK: - Private Helpers
private extension BookCellViewModel {
    
    // Set the rating state based on the book's rating
    func setRatingState() {
        if book.rating >= Constants.goodRating {
            state = .good
        } else if book.rating >= Constants.okayRating {
            state = .okay
        } else if book.rating >= Constants.mehRating {
            state = .meh
        } else {
            state = .bad
        }
    }
    
}
