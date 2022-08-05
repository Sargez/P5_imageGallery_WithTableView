//
//  ImageGallery.swift
//  imageGallery
//
//  Created by 1C on 09/07/2022.
//

import Foundation

class ImageGallery: Codable {
    var name: String
    var images: [ImageModel]
    
    init(title name: String, images:[ImageModel]) {
        self.name = name
        self.images = images
    }
}

struct ImageModel: Codable, Equatable {
    var url: URL
    var aspecrRatio: Double
    
    static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {return lhs.url == rhs.url}
    
}

extension Array where Element: Equatable {
    mutating func removeImageModel(at element: Element) {
        self.removeAll { $0 == element }
    }
}
