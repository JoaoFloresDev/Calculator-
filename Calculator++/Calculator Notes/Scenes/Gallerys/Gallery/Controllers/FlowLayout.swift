//
//  GalleryCollection.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 04/06/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

class FlowLayout: UICollectionViewFlowLayout {
    init(screenWidth: CGFloat) {
        super.init()
        sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        itemSize = CGSize(width: screenWidth/4, height: screenWidth/4)
        minimumInteritemSpacing = 20
        minimumLineSpacing = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
