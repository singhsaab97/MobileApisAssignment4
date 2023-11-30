//
//  BookCellViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import Foundation

protocol BookCellViewModelable {
    var book: Book { get }
    var state: BookCellViewModel.RatingState { get }
    var bookRating: String? { get }
    var creationDate: String { get }
}

final class BookCellViewModel: BookCellViewModelable {
    
    /// Determines the background color of book rating
    enum RatingState {
        case good
        case okay
        case meh
        case bad
        case unknown
    }
    
    let book: Book
    
    private(set) var state: RatingState
    
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
    
    private lazy var ratingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    init(book: Book) {
        self.book = book
        self.state = .unknown
        setRatingState()
    }
    
}

// MARK: - Exposed Helpers
extension BookCellViewModel {
    
    var bookRating: String? {
        return ratingFormatter.string(from: NSNumber(value: book.rating))
    }
    
    var creationDate: String {
        guard let dateString = book.creationDate,
              let inputDate = inputDateFormatter.date(from: dateString) else { return String() }
        return outputDateFormatter.string(from: inputDate)
    }
    
}

// MARK: - Private Helpers
private extension BookCellViewModel {
    
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
