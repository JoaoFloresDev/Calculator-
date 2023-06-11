//
//  CollectionViewCell.swift
//  Calculator Notes
//
//  Created by Joao Flores on 08/04/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    //MARK: - PROPERTIES
    
    @IBOutlet weak var selectedItem: UIImageView!
    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var viewPhoto: UIView!
    
    @IBOutlet weak var imageCell: UIImageView!
    
    var isInEditingMode: Bool = false {
        didSet {
            checkmarkLabel.isHidden = !isInEditingMode
            selectedItem.isHidden = !isInEditingMode
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                checkmarkLabel.text = isSelected ? "✓" : ""
                selectedItem.alpha = isSelected ? 0.5 : 0
            }
        }
    }
    
    func cropBounds(viewlayer: CALayer, cornerRadius: Float) {
        let imageLayer = viewlayer
        imageLayer.cornerRadius = CGFloat(cornerRadius)
        imageLayer.masksToBounds = true
    }
}

