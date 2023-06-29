//
//  BasicModels.swift
//  Calculator Notes
//
//  Created by João Victor  on 27/06/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import UIKit

struct Video {
    var image: UIImage
    var name: String
    var isSelected: Bool = false
}

struct Folder {
    var name: String
    var isSelected = false
}

struct Photo {
    var name: String
    var image: UIImage
    var isSelected: Bool = false
}
