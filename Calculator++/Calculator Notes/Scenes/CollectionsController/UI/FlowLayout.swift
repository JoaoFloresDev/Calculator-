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
    init(screenWidth: CGFloat, sizeRate: CGFloat = 4) {
        super.init()
        sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 10, right: 20)
        itemSize = CGSize(width: screenWidth/sizeRate, height: screenWidth/sizeRate)
        minimumInteritemSpacing = 20
        minimumLineSpacing = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collectionViewContentSize: CGSize {
        var contentSize = super.collectionViewContentSize
        let lastSectionFooterHeight: CGFloat = 70

        if collectionView?.numberOfSections ?? 0 > 0 {
            contentSize.height += lastSectionFooterHeight
        }

        return contentSize
    }
}
