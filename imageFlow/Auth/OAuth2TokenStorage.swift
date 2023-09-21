//
//  OAuth2TokenStorage.swift
//  imageFlow
//
//  Created by Александр Медведев on 12.08.2023.
//

import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    enum Keys: String {
        case bearerToken
    }
    var token: String? {
        get {
        guard let storedToken = userDefaults.string(forKey: Keys.bearerToken.rawValue) else { return nil }
        return storedToken
        }
        set {
            userDefaults.set(newValue, forKey:  Keys.bearerToken.rawValue)
        }
    }
}

