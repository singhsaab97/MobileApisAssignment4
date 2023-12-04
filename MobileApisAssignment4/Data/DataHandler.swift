//
//  DataHandler.swift
//  MobileApisAssignment4
//
//  Created by Ilham Sheikh on 15/11/23.
//

import Foundation

final class DataHandler {
    
    // Singleton instance for DataHandler
    static let shared = DataHandler()
    
    // Private initializer to enforce singleton pattern
    private init() {}
    
}

// MARK: - Exposed Helpers
extension DataHandler {
    
    // Sign up a new user
    func signUp(with firstName: String, lastName: String, emailId: String, password: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.register(
            firstName: firstName,
            lastName: lastName,
            emailId: emailId,
            password: password
        )
        initiateRequest(type: .post, with: targetApi, completion: completion)
    }
    
    // Sign in an existing user
    func signIn(with emailId: String, password: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.login(emailId: emailId, password: password)
        initiateRequest(type: .post, with: targetApi, completion: completion)
    }
    
    // Fetch a list of books
    func fetchBooks(with authToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.books(authToken: authToken)
        initiateRequest(type: .get, with: targetApi, completion: completion)
    }
    
    // Fetch details of a specific book
    func fetchBook(with bookId: String, authToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.book(id: bookId, authToken: authToken)
        initiateRequest(type: .get, with: targetApi, completion: completion)
    }
    
    // Add a new book
    func addBook(_ book: Book, authToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.create(book: book, authToken: authToken)
        initiateRequest(type: .post, with: targetApi, completion: completion)
    }
    
    // Update details of an existing book
    func updateBook(_ book: Book, authToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.update(book: book, authToken: authToken)
        initiateRequest(type: .put, with: targetApi, completion: completion)
    }
    
    // Delete a book
    func deleteBook(with bookId: String, authToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.delete(id: bookId, authToken: authToken)
        initiateRequest(type: .delete, with: targetApi, completion: completion)
    }
    
}

// MARK: - Private Helpers
private extension DataHandler {
    
    // Function to initiate an HTTP request
    func initiateRequest(type: RequestType, with targetApi: ApiConstructor, completion: @escaping (Result<Data, Error>) -> Void) {
        // Create request
        var request = URLRequest(url: targetApi.endpointUrl)
        request.httpMethod = type.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch targetApi {
        case .register, .login:
            break
        case let .books(token),
            let .book(_, token),
            let .create(_, token),
            let .update(_, token),
            let .delete(_, token):
            // Set Authorization header for requests requiring authentication
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let params = targetApi.bodyParams,
           let requestBody = try? JSONSerialization.data(withJSONObject: params)  {
            request.httpBody = requestBody
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let error = error else {
                if let data = data {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: Constants.genericResponseError, code: 0)
                    completion(.failure(error))
                }
                return
            }
            completion(.failure(error))
        }
        // Start the task
        task.resume()
    }
    
}
