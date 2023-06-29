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
    
    var isSelectedCell: Bool = false {
        didSet {
            checkmarkLabel.text = isSelectedCell ? "✓" : ""
            selectedItem.alpha = isSelectedCell ? 0.5 : 0
        }
    }
}
