//
//  ApiConstructor.swift
//  MobileApisAssignment4
//
//  Created by Ilham Sheikh on 15/11/23.
//

import Foundation

// Enum defining different types of HTTP requests
enum RequestType {
    case get
    case post
    case put
    case delete
}

// Enum defining various API requests with associated data
enum ApiConstructor {
    case register(firstName: String, lastName: String, emailId: String, password: String)
    case login(emailId: String, password: String)
    case books(authToken: String)
    case book(id: String, authToken: String)
    case create(book: Book, authToken: String)
    case update(book: Book, authToken: String)
    case delete(id: String, authToken: String)
}

// MARK: - Exposed Helpers
extension ApiConstructor {
    
    // Computed property to get the endpoint URL for the API request
    var endpointUrl: URL! {
        let urlPath: String
        switch self {
        case .register:
            urlPath = "auth/register"
        case .login:
            urlPath = "auth/login"
        case .books:
            urlPath = "book"
        case let .book(id, _):
            urlPath = "book/\(id)"
        case .create:
            urlPath = "book/create"
        case let .update(book, _):
            urlPath = "book/update/\(book.id)"
        case let .delete(id, _):
            urlPath = "book/del/\(id)"
        }
        // Construct and return the full URL by combining the base URL and the endpoint path
        return URL(string: "\(Constants.baseUrlPath)\(urlPath)")
    }
    
    // Computed property to get the body parameters for the API request
    var bodyParams: [String: Any]? {
        switch self {
        case let .register(firstName, lastName, emailId, password):
            return [
                "firstName": firstName,
                "lastName": lastName,
                "email": emailId,
                "password": password
            ]
        case let .login(emailId, password):
            return [
                "email": emailId,
                "password": password
            ]
        case let .create(book, _),
            let .update(book, _):
            return [
                // Map the Book properties to the corresponding API parameters
                Book.CodingKeys.name.rawValue: book.name,
                Book.CodingKeys.rating.rawValue: book.rating,
                Book.CodingKeys.author.rawValue: book.author,
                Book.CodingKeys.genre.rawValue: book.genre
            ]
        case .books, .book, .delete:
            return nil
        }
    }
    
}

// MARK: - Request Helpers
extension RequestType {
    
    // Computed property to get the HTTP method string for the request
    var method: String {
        switch self {
        case .get:
            return Constants.getMethod
        case .post:
            return Constants.postMethod
        case .put:
            return Constants.putMethod
        case .delete:
            return Constants.deleteMethod
        }
    }
    
}
