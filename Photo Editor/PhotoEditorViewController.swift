//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

extension PhotoEditorViewController:UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: UIScreen.main.bounds.size.width, height: self.clsView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let img = image {
            return img.count
        } else {
            return 0
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        view.endEditing(true)
//        doneButton.isHidden = true
//        colorPickerView.isHidden = true
//        hideToolbar(hide: false)
//        isDrawing = false
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.canvasIndex = Int(pageNumber)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImgCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgCell", for: indexPath as IndexPath) as! ImgCell
        if let img = image {
            cell.setImageView(image: img[indexPath.item].0, subviews:img[indexPath.item].1)
        }
        return cell
    }
}

public final class PhotoEditorViewController: UIViewController {
    var canvasIndex = 0
    var isErasing = false
//    isErasing
    @IBOutlet weak var clsView: UICollectionView!
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!

    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!

    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnErase: UIButton!
    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    public var image: [(UIImage,[String: Any?]?)]?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors  : [UIColor] = []
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    public var hiddenControls : [control] = []
    
    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
   
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    
    
    // MARK: - Brush Changes
    var currentBrushSize: CGFloat = 5.0
    @IBOutlet weak var brushSizeSlider: UISlider!
    @IBOutlet weak var brushSizeView: UIView!
    
    // MARK: - Opacity Changes
    var currentColorOpacity: CGFloat = 1.0
    @IBOutlet weak var opacitySizeSlider: UISlider!
    @IBOutlet weak var OpacityView: UIStackView!
    
    var stickersViewController: StickersViewController!
    //Register Custom font before we load XIB
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.clsView.register(UINib.init(nibName: "ImgCell", bundle:nil), forCellWithReuseIdentifier: "ImgCell")
        self.clsView.delegate = self
        self.clsView.dataSource = self
        self.clsView.reloadData()
        
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
        
        
        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
//        hideControls()
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    func hideToolbar(hide: Bool) {
//        DispatchQueue.main.async {
            self.topToolbar.isHidden = hide
            self.topGradient.isHidden = hide
            self.bottomToolbar.isHidden = hide
            self.bottomGradient.isHidden = hide
            self.loadViewIfNeeded()
//        }
    }
    
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
            self.isErasing = false
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}





