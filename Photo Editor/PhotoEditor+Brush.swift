//
//  PhotoEditor+Brush.swift
//  NewDemo
//
//  Created by Elaunch7 on 11/07/18.
//  Copyright © 2018 Elaunch7. All rights reserved.
//

import Foundation
import UIKit
extension PhotoEditorViewController {
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = sender.value
        print("currentValue :\(currentValue)")
        brushSizeSlider.setValue(currentValue, animated: true)
        currentBrushSize = CGFloat(currentValue)
    }
    
    @IBAction func IncreaseBrushSize(sender: Any) {
        if currentBrushSize < 10 {
            currentBrushSize = currentBrushSize + 1
            brushSizeSlider.setValue(Float(currentBrushSize), animated: true)
        }
    }
    
    @IBAction func DecreaseBrushSize(sender: Any) {
        if currentBrushSize > 5 {
            currentBrushSize = currentBrushSize - 1
            brushSizeSlider.setValue(Float(currentBrushSize), animated: true)
        }
    }
    
    @IBAction func EraseDrawing(sender: Any) {
        isErasing = true
    }
}
