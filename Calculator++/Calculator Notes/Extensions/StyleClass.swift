//
//  styleFunctions.swift
//  App
//
//  Created by Joao Flores on 27/04/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
//

import UIKit

class StyleClass {

    func cropBounds(viewlayer: CALayer, cornerRadius: Float) {
        
        let imageLayer = viewlayer
        imageLayer.cornerRadius = CGFloat(cornerRadius)
        imageLayer.masksToBounds = true
    }
    
    func applicShadow(Layer: CALayer) {
        
        Layer.masksToBounds = false
        Layer.shadowPath = UIBezierPath(rect: Layer.bounds).cgPath
        Layer.shouldRasterize = true
        
        Layer.shadowColor = UIColor.black.cgColor
        Layer.shadowOpacity = 0.2
        Layer.shadowOffset = CGSize.zero
        Layer.shadowRadius = 6
    }
    
    func applicGradient(view: UIView) {
        let mask = CAGradientLayer()
        mask.startPoint = CGPoint(x: 0.0, y: 0.0)
        mask.endPoint = CGPoint(x: 0.0, y: 1.5)
        let whiteColor = UIColor.white
        mask.colors = [whiteColor.withAlphaComponent(0.0).cgColor,whiteColor.withAlphaComponent(1.0),whiteColor.withAlphaComponent(1.0).cgColor]
        mask.locations = [NSNumber(value: 0.0),NSNumber(value: 0.2),NSNumber(value: 1.0)]
        
        view.backgroundColor = UIColor.white
        mask.frame = view.bounds
        view.layer.mask = mask
    }
}


