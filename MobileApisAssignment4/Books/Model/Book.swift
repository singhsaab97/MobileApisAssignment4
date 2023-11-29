//
//  Book.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import Foundation

struct Book: Codable {
    let id: String
    let name: String
    let rating: Double
    let author: String
    let genre: String
    let creationDate: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name = "BookName"
        case rating = "Rating"
        case author = "Author"
        case genre = "Genre"
        case creationDate = "createdDate"
    }
    
}
