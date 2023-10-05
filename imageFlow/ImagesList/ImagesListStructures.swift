//
//  ImagesListStructures.swift
//  imageFlow
//
//  Created by Александр Медведев on 03.10.2023.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: Urls
    let likedByUser: Bool
}

struct Urls: Decodable {
    let thumb: String
    let full: String
}


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date
    let description: String
    let thumbImageURL: String
    let largeImageURL: String
    let likedByUser: Bool
}
