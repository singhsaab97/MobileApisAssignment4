//
//  LocalStorage.swift
//  MobileApisAssignment4
//
//  Created by Kosisochukwu Abone on 04/12/23.
//

import Foundation

extension UserDefaults {
    
    static let appSuite = UserDefaults(suiteName: "MobileApisAssignment4") ?? UserDefaults()
    static let authTokenKey = "authTokenKey"
    
}
