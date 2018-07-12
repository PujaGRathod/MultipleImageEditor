//
//  PhotoEditor+Opacity.swift
//  NewDemo
//
//  Created by Elaunch7 on 12/07/18.
//  Copyright © 2018 Elaunch7. All rights reserved.
//


import Foundation
import UIKit
extension PhotoEditorViewController {
    
    @IBAction func opacitySliderValueChanged(sender: UISlider) {
        let currentValue = sender.value
        opacitySizeSlider.setValue(currentValue, animated: true)
        currentColorOpacity = CGFloat(currentValue)
//        textColor = textColor.withAlphaComponent(currentColorOpacity)
    }
    
    @IBAction func IncreaseOpacitySize(sender: Any) {
        if currentColorOpacity < 1 {
            currentColorOpacity = currentColorOpacity + 0.1
            opacitySizeSlider.setValue(Float(currentColorOpacity), animated: true)
//            textColor = textColor.withAlphaComponent(currentColorOpacity)
        }
    }
    
    @IBAction func DecreaseOpacitySize(sender: Any) {
        if currentColorOpacity > 1 {
            currentColorOpacity = currentColorOpacity - 0.1
            opacitySizeSlider.setValue(Float(currentColorOpacity), animated: true)
//            textColor = textColor.withAlphaComponent(currentColorOpacity)
        }
    }
}
