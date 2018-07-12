//
//  PhotoEditor+Drawing.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

extension PhotoEditorViewController {
    
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            swiped = false
            if let touch = touches.first {
                 let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                lastPoint = touch.location(in: cell.canvasImageView)
            }
        }
            //Hide stickersVC if clicked outside it
        else if stickersVCIsVisible == true {
            if let touch = touches.first {
                let location = touch.location(in: self.view)
                if !stickersViewController.view.frame.contains(location) {
                    removeStickersView()
                }
            }
        }
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            // 6
            swiped = true
            if let touch = touches.first {
                let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                let currentPoint = touch.location(in: cell.canvasImageView)
                drawLineFromNew(lastPoint, toPoint: currentPoint)
                
                // 7
                lastPoint = currentPoint
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            if !swiped {
                // draw a single point
                drawLineFromNew(lastPoint, toPoint: lastPoint)
            }
        }
        
    }
    
    func drawLineFromNew(_ fromPoint: CGPoint, toPoint: CGPoint) {

        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext((cell.canvasImageView.frame.size))

        // Draw the starting image in the current context as background
        cell.canvasImageView.image?.draw(at: CGPoint.zero)

        // Get the current context
        let context = UIGraphicsGetCurrentContext()!

        context.setLineWidth(currentBrushSize)
        context.setStrokeColor(drawColor.cgColor)
        context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        if isErasing {
            context.setBlendMode(.clear)
        } else {
            context.setStrokeColor(drawColor.cgColor)
            context.setAlpha(currentColorOpacity)
            context.setBlendMode(CGBlendMode.normal)
        }
        context.strokePath()

        // Draw a transparent green Circle
        context.setStrokeColor(drawColor.cgColor)
        context.setAlpha(currentColorOpacity)
        context.setLineWidth(currentBrushSize)
        
        context.drawPath(using: .stroke) // or .fillStroke if need filling

        cell.canvasImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Save the context as a new UIImage
    }
    
//    func drawLineFromNew(_ fromPoint: CGPoint, toPoint: CGPoint) {
//        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
//        // 1
//        UIGraphicsBeginImageContext(cell.canvasImageView.frame.size)
//        if let context = UIGraphicsGetCurrentContext() {
//            cell.canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width:cell.canvasImageView.frame.size.width, height: cell.canvasImageView.frame.size.height))
//            // 2
//            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
//            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
//            // 3
//            context.setLineCap(CGLineCap.round)
//            context.setLineWidth(currentBrushSize)
//            if isErasing {
//                context.setBlendMode(.clear)
//            } else {
//                context.setStrokeColor(drawColor.cgColor)
//                context.setAlpha(currentColorOpacity)
//                context.setBlendMode(CGBlendMode.normal)
//
////                context.setFillColor(drawColor.withAlphaComponent(currentColorOpacity).cgColor)
//            }
//            // 4
//            context.strokePath()
//            // 5
//            cell.canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//        }
//    }
}

class ScaledHeightImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        
        return CGSize(width: -1.0, height: -1.0)
    }
    
}
