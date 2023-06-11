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
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)
        let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: collectionView!.numberOfSections - 1))

        if let footerAttributes = footerAttributes {
            layoutAttributes?.append(footerAttributes)
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)

        if elementKind == UICollectionElementKindSectionFooter && indexPath.section == collectionView!.numberOfSections - 1 {
            let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            let contentWidth = collectionViewContentSize.width - sectionInset.left - sectionInset.right
            let footerHeight: CGFloat = 70

            footerAttributes.frame = CGRect(x: sectionInset.left, y: attributes?.frame.maxY ?? 0, width: contentWidth, height: footerHeight)

            return footerAttributes
        }

        return attributes
    }
    

    override var collectionViewContentSize: CGSize {
        var contentSize = super.collectionViewContentSize
        let lastSectionFooterHeight: CGFloat = 70

        if collectionView!.numberOfSections > 0 {
            contentSize.height += lastSectionFooterHeight
        }

        return contentSize
    }
}
