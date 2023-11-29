//
//  ApiConstructor.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import Foundation

enum RequestType {
    case get
    case post
}

enum ApiConstructor {
    case register(firstName: String, lastName: String, emailId: String, password: String)
    case login(emailId: String, password: String)
    case books(authToken: String)
}

// MARK: - Exposed Helpers
extension ApiConstructor {
    
    var endpointUrl: URL! {
        let urlPath: String
        switch self {
        case .register:
            urlPath = "auth/register"
        case .login:
            urlPath = "auth/login"
        case .books:
            urlPath = "book"
        }
        return URL(string: "\(Constants.baseUrlPath)\(urlPath)")
    }
    
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
        case .books:
            return nil
        }
    }
    
}

// MARK: - Request Helpers
extension RequestType {
    
    var method: String {
        switch self {
        case .get:
            return Constants.getMethod
        case .post:
            return Constants.postMethod
        }
    }
    
}
