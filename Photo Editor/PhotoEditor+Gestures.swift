//
//  PhotoEditor+Gestures.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation


import UIKit
extension UIImageView{
    
//    func imageFrame() -> CGRect {
//
//         let imageViewSize = self.frame.size
//         var imageSize = self.image?.size
//
//        let scalW = imageViewSize.width / (imageSize?.width)!
//        let scalH = imageViewSize.height / (imageSize?.height)!
//        let aspect = fmin(scalW, scalH)
//        let width = (imageSize?.width)! * aspect
//        let height = (imageSize?.height)! * aspect
//        imageSize?.width = width
//        imageSize?.height = height
//
//        return CGRect.init(x: 0, y: 0, width: (imageSize?.width)!, height: (imageSize?.height)!)
////            CGRectMake(0,0,imgSize.width*=aspect,imgSize.height*=aspect)
//
//
//
////        CGSize imgViewSize=self.frame.size;                  // Size of UIImageView
////        CGSize imgSize=self.image.size;                      // Size of the image, currently displayed
////
////        // Calculate the aspect, assuming imgView.contentMode==UIViewContentModeScaleAspectFit
////
////        CGFloat scaleW = imgViewSize.width / imgSize.width;
////        CGFloat scaleH = imgViewSize.height / imgSize.height;
////        CGFloat aspect=fmin(scaleW, scaleH);
////
////        CGRect imageRect={ {0,0} , { imgSize.width*=aspect, imgSize.height*=aspect } };
////
////        // Note: the above is the same as :
////        // CGRect imageRect=CGRectMake(0,0,imgSize.width*=aspect,imgSize.height*=aspect) I just like this notation better
////
////        // Center image
////
////        imageRect.origin.x=(imgViewSize.width-imageRect.size.width)/2;
////        imageRect.origin.y=(imgViewSize.height-imageRect.size.height)/2;
////
////        // Add imageView offset
////
////        imageRect.origin.x+=self.frame.origin.x;
////        imageRect.origin.y+=self.frame.origin.y;
//
//    }
    func imageFrame()->CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: topLeftX, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}
extension PhotoEditorViewController : UIGestureRecognizerDelegate  {
    
    /**
     UIPanGestureRecognizer - Moving Objects
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as? ImgCell {
            if let view = recognizer.view {
                
                if view is UIImageView && isDrawing {
                    //                    let size = cell.imageView.image?.suitableSize(widthLimit: UIScreen.main.bounds.width)
                    //                    cell.canvasImageView.frame.size =  cell.imageView.image.
                    //Tap only on visible parts on the image
                    if recognizer.state == .began {
                        if isDrawing {
                            let location = recognizer.location(in: cell.canvasImageView)
                            let currentPoint = location
                            lastPoint = currentPoint
                        }
                    } else if recognizer.state == .changed {
                        if isDrawing {
                            let location = recognizer.location(in: cell.canvasImageView)
                            let currentPoint = location
                            drawLineFromNew(lastPoint, toPoint: currentPoint)
                            lastPoint = currentPoint
                        }
                    }
                } else if view is UIImageView  {
                    //Tap only on visible parts on the image
                    if recognizer.state == .began {
                        for imageView in subImageViews(view: cell.canvasImageView!) {
                            let location = recognizer.location(in: imageView)
                            let alpha = imageView.alphaAtPoint(location)
                            if alpha > 0 {
                                imageViewToPan = imageView
                                break
                            }
                        }
                    }
                    if imageViewToPan != nil {
                        moveView(view: imageViewToPan!, recognizer: recognizer)
                    }
                }
                else {
                    self.moveView(view: view, recognizer: recognizer)
                }
                
                //
                //            else if view is UIImageView  {
                //                //Tap only on visible parts on the image
                //                if recognizer.state == .began {
                //                    for imageView in subImageViews(view: cell.canvasImageView) {
                //                        let location = recognizer.location(in: imageView)
                //                        let alpha = imageView.alphaAtPoint(location)
                //                        if alpha > 0 {
                //                            imageViewToPan = imageView
                //                            break
                //                        }
                //                    }
                //                }
                //                if imageViewToPan != nil {
                //                    moveView(view: imageViewToPan!, recognizer: recognizer)
                //                }
                //            }
                ////            else if view is UITextView {
                ////                if isTextEditingAllowed {
                ////                    moveView(view: view, recognizer: recognizer)
                ////                }
                ////            }
                //            else {
                //                moveView(view: view, recognizer: recognizer)
                //            }
            }
        }
    }
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doen't look pixlated
     */
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextView {
                let textView = view as! UITextView
                if textView.font!.pointSize * recognizer.scale < 90 {
                    let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
                    textView.font = font
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                } else {
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                }
                textView.setNeedsDisplay()
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
   @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
    let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                for imageView in subImageViews(view: cell.canvasImageView!) {
                    let location = recognizer.location(in: imageView)
                    let alpha = imageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: imageView)
                        break
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    /*
     Support Multiple Gesture at the same time
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            if !stickersVCIsVisible {
                addStickersViewController()
            }
        }
    }
    
    // to Override Control Center screen edge pan from bottom
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
     Scale Effect
     */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubview(toFront: view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
    /**
     Moving Objects 
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */

    func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
        
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        
        hideToolbar(hide: true)
        deleteView.isHidden = false
        
        view.superview?.bringSubview(toFront: view)
        let pointToSuperView = recognizer.location(in: self.view)

        view.center = CGPoint(x: view.center.x + recognizer.translation(in: cell.canvasImageView).x,
                              y: view.center.y + recognizer.translation(in: cell.canvasImageView).y)
        recognizer.setTranslation(CGPoint.zero, in: cell.canvasImageView)
        
        if let previousPoint = lastPanPoint {
            //View is going into deleteView
            if deleteView.frame.contains(pointToSuperView) && !deleteView.frame.contains(previousPoint) {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
                    view.center = recognizer.location(in: cell.canvasImageView)
                })
            }
                //View is going out of deleteView
            else if deleteView.frame.contains(previousPoint) && !deleteView.frame.contains(pointToSuperView) {
                //Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 4, y: 4)
                    view.center = recognizer.location(in: cell.canvasImageView)
                })
            }
        }
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
            hideToolbar(hide: false)
            deleteView.isHidden = true
            let point = recognizer.location(in: self.view)
            
            if deleteView.frame.contains(point) { // Delete the view
                view.removeFromSuperview()
                if #available(iOS 10.0, *) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } else if !(cell.canvasImageView?.bounds.contains(view.center))! { //Snap the view back to canvasImageView
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = (cell.canvasImageView?.center)!
                })
                
            }
        }
    }
    
    func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if imageView is UIImageView {
                imageviews.append(imageView as! UIImageView)
            }
        }
        return imageviews
    }
}
