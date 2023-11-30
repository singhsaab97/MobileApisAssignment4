//
//  Book.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import Foundation

struct Book: Codable {
    let id: String
    var name: String
    var rating: Double
    var author: String
    var genre: String
    let creationDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name = "BookName"
        case rating = "Rating"
        case author = "Author"
        case genre = "Genre"
        case creationDate = "createdDate"
    }
    
}

// MARK: - Exposed Helpers
extension Book {
    
    static var newObject: Book {
        return Book(
            id: String(),
            name: String(),
            rating: .zero,
            author: String(),
            genre: String(),
            creationDate: nil
        )
    }
    
    func isEqual(to book: Book) -> Bool {
        return name == book.name
            && rating == book.rating
            && author == book.author
            && genre == book.genre
    }
    
}
