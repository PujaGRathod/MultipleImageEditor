//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - Control
public enum control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

extension PhotoEditorViewController {

     //MARK: Top Toolbar
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonTapped(_ sender: UIButton) {
        let controller = CropViewController()
        controller.delegate = self
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        controller.image = cell.imageView.image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }

    @IBAction func drawButtonTapped(_ sender: Any) {
//        isDrawing = true
//        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
//        cell.canvasImageView.isUserInteractionEnabled = true
//        addGestures(view: cell.canvasImageView)
////        cell.canvasImageView.frame = cell.imageView.imageFrame()
////        cell.layoutIfNeeded()
//        doneButton.isHidden = false
//        colorPickerView.isHidden = false
//        hideToolbar(hide: true)
        
        self.isErasing = false
        isDrawing = true
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        cell.canvasImageView.isUserInteractionEnabled = false
        addGestures(view: cell.canvasImageView)
        doneButton.isHidden = false
        self.brushSizeView.isHidden = false
        self.OpacityView.isHidden = false
        colorPickerView.isHidden = false
        btnErase.isHidden = false
        hideToolbar(hide: true)
    }

    @IBAction func textButtonTapped(_ sender: Any) {
        
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        let textView = UITextView(frame: CGRect(x: 0, y: cell.canvasImageView.frame.size.height/2 - 15,
                                                width: UIScreen.main.bounds.width, height: 30))
        isTyping = true
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        
        cell.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
        textView.isUserInteractionEnabled = true
        colorPickerView.isHidden = false
        doneButton.isHidden = false
        self.brushSizeView.isHidden = true
        self.OpacityView.isHidden = true
        btnErase.isHidden = true
        hideToolbar(hide: true)
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        self.isDrawing = false
        self.isErasing = false
        self.view.endEditing(true)
        self.doneButton.isHidden = true
        self.brushSizeView.isHidden = true
        self.OpacityView.isHidden = true
        self.btnErase.isHidden = true
        self.colorPickerView.isHidden = true
        cell.canvasImageView.isUserInteractionEnabled = true
        self.hideToolbar(hide: false)
    }
    
    //MARK: Bottom Toolbar
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        //clear drawing
        cell.canvasImageView.image = nil
        //clear stickers and textviews
        for subview in cell.canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        
        var Dictionary = [String: Any]()
        
        if let image = cell.canvasImageView.image {
            Dictionary["image"] = image
        }
        
        var arrSubviews:[Any] = []
        if cell.canvasImageView.subviews.count > 0 {
            arrSubviews.append(cell.canvasImageView.subviews)
        }
        
        if arrSubviews.count > 0 {
            Dictionary["subViews"] = arrSubviews
        }
        
        
        self.image![IndexPath.init(row: self.canvasIndex, section: 0).item].1 = Dictionary
        if self.canvasIndex > 0 {
            self.canvasIndex = self.canvasIndex - 1
        }
        self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
        view.layoutIfNeeded()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell

        var Dictionary = [String: Any]()
        
        if let image = cell.canvasImageView.image {
            Dictionary["image"] = image
        }
        
        
        var arrSubviews:[Any] = []
        if cell.canvasImageView.subviews.count > 0 {
            arrSubviews.append(cell.canvasImageView.subviews)
        }
        
        if arrSubviews.count > 0 {
            Dictionary["subViews"] = arrSubviews
        }
        self.image![IndexPath.init(row: self.canvasIndex, section: 0).item].1 = Dictionary
        if self.canvasIndex < ((self.image?.count)!-1) {
            self.canvasIndex = self.canvasIndex + 1
        }
        
        self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
        view.layoutIfNeeded()
    }

    //MAKR: helper methods
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideControls() {
        for control in hiddenControls {
            switch control {
                
            case .clear:
                clearButton.isHidden = true
            case .crop:
                cropButton.isHidden = true
            case .draw:
                drawButton.isHidden = true
            case .save:
                saveButton.isHidden = true
            case .share:
                shareButton.isHidden = true
            case .sticker:
                stickerButton.isHidden = true
            case .text:
                stickerButton.isHidden = true
            }
        }
    }
    
}
