//
//  Book.swift
//  MobileApisAssignment4
//
//  Created by Kosisochukwu Abone on 15/11/23.
//

import Foundation

// Book structure conforming to Codable for easy encoding and decoding
struct Book: Codable {
    let id: String
    var name: String
    var rating: Double
    var author: String
    var genre: String
    let creationDate: String?
    
    // CodingKeys to map between property names in the Swift code and the JSON keys
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
    
    // A static property providing a new default Book object
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
    
    // Compare if two Book objects are equal based on certain properties
    func isEqual(to book: Book) -> Bool {
        return name == book.name
            && rating == book.rating
            && author == book.author
            && genre == book.genre
    }
    
}
