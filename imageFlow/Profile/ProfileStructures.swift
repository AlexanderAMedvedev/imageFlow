//
//  ProfileStructures.swift
//  imageFlow
//
//  Created by Александр Медведев on 19.09.2023.
//

import Foundation

struct ProfileResult: Codable {
    var username: String
    var firstName: String?
    var lastName: String?
    var bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    var username: String
    var name: String
    var loginName: String
    var bio: String
}

struct UserResult: Codable {
    var profileImageURLs: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case profileImageURLs = "profile_image"
    }
}
