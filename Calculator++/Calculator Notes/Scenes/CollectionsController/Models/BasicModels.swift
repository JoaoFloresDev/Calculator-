//
//  BasicModels.swift
//  Calculator Notes
//
//  Created by João Victor  on 27/06/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import UIKit

struct Folder {
    var name: String
    var isSelected = false
}

struct Photo {
    var name: String
    var image: UIImage
    var thumbImage: UIImage?
    var isSelected: Bool = false
}

extension UIImage {
    func resizedTo150x150() -> UIImage {
        let minDimension: CGFloat = 100
        let aspectRatio = max(minDimension / self.size.width, minDimension / self.size.height)
        
        let newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
