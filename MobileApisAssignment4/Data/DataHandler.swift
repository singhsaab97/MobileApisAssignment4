//
//  DataHandler.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import Foundation

final class DataHandler {
    
    static let shared = DataHandler()
    
    private init() {}
    
}

// MARK: - Exposed Helpers
extension DataHandler {
    
    func signUp(with firstName: String, lastName: String, emailId: String, password: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.register(
            firstName: firstName,
            lastName: lastName,
            emailId: emailId,
            password: password
        )
        initiateRequest(type: .post, with: targetApi, completion: completion)
    }
    
    func signIn(with emailId: String, password: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.login(emailId: emailId, password: password)
        initiateRequest(type: .post, with: targetApi, completion: completion)
    }
    
    func fetchBooks(with authToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let targetApi = ApiConstructor.books(authToken: authToken)
        initiateRequest(type: .get, with: targetApi, completion: completion)
    }
    
}

// MARK: - Private Helpers
private extension DataHandler {
    
    func initiateRequest(type: RequestType, with targetApi: ApiConstructor, completion: @escaping (Result<Data, Error>) -> Void) {
        // Create request
        var request = URLRequest(url: targetApi.endpointUrl)
        request.httpMethod = type.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch targetApi {
        case .register, .login:
            break
        case let .books(token):
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
