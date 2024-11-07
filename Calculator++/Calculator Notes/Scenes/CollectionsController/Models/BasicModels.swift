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
        let targetSize = CGSize(width: 150, height: 150)
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 0)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}
