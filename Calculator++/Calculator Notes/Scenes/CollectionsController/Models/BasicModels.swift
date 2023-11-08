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
    var isSelected: Bool = false
}

extension UIImage
{
    func scale(newWidth: CGFloat) -> UIImage
    {
        guard self.size.width != newWidth else{return self}
        
        let scaleFactor = newWidth / self.size.width
        
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
