//
//  OAuth2TokenStorage.swift
//  imageFlow
//
//  Created by Александр Медведев on 12.08.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
  //private let userDefaults = UserDefaults.standard
  //  enum Keys: String {
  //      case bearerToken
  //  }
    var token: String? {
        get {
            let storedToken: String? = KeychainWrapper.standard.string(forKey: "Auth token")
            return storedToken
        //guard let storedToken = userDefaults.string(forKey: Keys.bearerToken.rawValue) else { return nil }
        //return storedToken
        }
        set {
            if newValue == nil {
                let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "Auth token")
                guard removeSuccessful else {
                    print("The token is not removed from KeyChain")
                    return
                }
                        print("The token is removed from KeyChain")
                return
            }
            guard let authToken = newValue else {
                print("Did not open optional with the token")
                return
            }
            let isSuccess = KeychainWrapper.standard.set(authToken, forKey: "Auth token")
            guard isSuccess else {
                print("Did not write the token into keychain")
                return
            }
          //  userDefaults.set(newValue, forKey:  Keys.bearerToken.rawValue)
        }
    }
}

