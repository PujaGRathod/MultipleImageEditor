//
//  ViewController.swift
//  NewDemo
//
//  Created by Elaunch7 on 05/07/18.
//  Copyright © 2018 Elaunch7. All rights reserved.
//

import UIKit
import OpalImagePicker

extension ViewController:OpalImagePickerControllerDelegate,PhotoEditorDelegate {
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        let arrImages  = images
        self.dismiss(animated: true) {
            self.showImageEditor(images: arrImages)
        }
    }
    
    func showImageEditor(images: [UIImage]) {
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        //PhotoEditorDelegate-
        photoEditor.photoEditorDelegate = self
        
        //The image to be edited
//        photoEditor.image = images
        
        var imagesValue: [(UIImage,[String: Any?]?)] = []
        
        for i in images {
            imagesValue.append((i, nil))
        }

        photoEditor.image = imagesValue
        
        //Stickers that the user will choose from to add on the image
        
        for i in 0...10 {
            photoEditor.stickers.append(UIImage(named: i.description)!)
        }
        
        self.present(photoEditor, animated: true, completion: nil)
    }

//    optional func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset])
//    optional func imagePickerDidCancel(_ picker: OpalImagePickerController)
}

class ViewController: UIViewController {
    func doneEditing(image: UIImage) {
        print("cell")
    }
    
    func canceledEditing() {
        
    }
    
    @IBAction func btnClick(_ sender: Any) {
        
        
        let imagePicker = OpalImagePickerController()
        imagePicker.imagePickerDelegate = self
        present(imagePicker, animated: true, completion: nil)
        
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()            
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

