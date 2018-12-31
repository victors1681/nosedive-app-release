//
//  PhotoDisplayController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/24/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoDisplayController: UIViewController, UIScrollViewDelegate {
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            
            let url = URL(string: post.imageUrl)
            image.kf.setImage(with: url)
            initialImageView.image = image.image
            imageViewBg.image = image.image
            
            guard let userInfo = post.user else { return }
            
            let attributedText = NSMutableAttributedString(string: userInfo.username, attributes: [NSAttributedStringKey.font: UIFont.init(name: "AvenirNext-DemiBold", size: 13) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white])
            
            
            attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 13) ?? UIFont(), NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            caption.attributedText = attributedText
            
            setCommentCount(post.comments)
        }
    }
    
    let closeBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "close-button-shadow"), for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.contentVerticalAlignment = .top
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    let commentsBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("Comments", for: .normal)
        btn.titleLabel?.font = DefaultFont.medium.size(15)
        btn.contentHorizontalAlignment = .left
        btn.contentVerticalAlignment = .top
        btn.addTarget(self, action: #selector(handlerComments), for: .touchUpInside)
        return btn
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    let background : UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let ve = UIVisualEffectView(effect: effect)
        return ve
    }()
    
    let caption: UITextView = {
        let tv = UITextView()
        tv.text = ""
        tv.font = UIFont(name: "AvenirNext-Regular", size: 13)
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.tintColor = .white
        tv.isSelectable = false
        return tv
    }()
    
    let captionContainer : UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let ve = UIVisualEffectView(effect: effect)
        return ve
    }()
    
    lazy var image: UIImageView = {
        let i = UIImageView()
        i.contentMode = .center
        i.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleClose))
        i.addGestureRecognizer(tap)
        return i
    }()
    
    lazy var initialImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.layer.masksToBounds = true
        
        return i
    }()

    lazy var imageViewBg: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.layer.masksToBounds = true
        
        return i
    }()
    
    @objc func handleClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlerComments(){
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        //commentsController.cell = cell
        commentsController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.present(commentsController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initGesture()
        
        self.setupLayout()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        UIView.animate(withDuration: 1) {
            self.closeBtn.alpha = 1
            self.captionContainer.alpha = 0
        }
        
       
        
        
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        
        scrollView.setZoomScale(minScale, animated: false)
        
        print( self.scrollView.contentOffset.y, minScale, image.frame.origin.y, scrollView.contentSize.height)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.initialImageView.frame = CGRect(x: 0, y: self.image.frame.origin.y, width: self.view.frame.size.width, height: self.scrollView.contentSize.height)
        }, completion: { (success) in
            self.initialImageView.removeFromSuperview()
        })
        
        let cOriginal = captionContainer.frame
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.closeBtn.alpha = 1
            self.captionContainer.alpha = 1
            self.captionContainer.frame = CGRect(x: cOriginal.origin.x, y: cOriginal.origin.y-20, width: cOriginal.size.width, height: cOriginal.size.height)
            
        }, completion: nil)
    }
    
    func setupLayout(){
        captionContainer.alpha = 0
        
        view.addSubview(imageViewBg)
        imageViewBg.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(background)
        background.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        closeBtn.alpha = 0
        
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(scrollView)
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        image.frame = CGRect(x: view.frame.size.width / 2, y: view.frame.size.height / 2, width: (image.image?.size.width)!, height: (image.image?.size.height)!)
        scrollView.addSubview(image)
        
        guard let img = image.image else  { return }
        scrollView.contentSize = img.size
        
        centerScrollViewContents()
        
        view.addSubview(closeBtn)
        
        closeBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 60, height: 60, safeArea: true, view: view)
        
        view.addSubview(initialImageView)
        initialImageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        view.addSubview(captionContainer)
        let contentSize = self.caption.sizeThatFits(self.view.frame.size)
        captionContainer.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: contentSize.height + 30 + Helpers().getSafeAreaSize().bottom)
        
        captionContainer.contentView.addSubview(caption)
        
        caption.anchor(top: captionContainer.topAnchor, left: captionContainer.leftAnchor, bottom: nil, right: captionContainer.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        
        let cOriginal = captionContainer.frame
        captionContainer.frame = CGRect(x: cOriginal.origin.x, y: cOriginal.origin.y + 20, width: cOriginal.size.width, height: cOriginal.size.height)
        
        
        captionContainer.contentView.addSubview(commentsBtn)
        commentsBtn.anchor(top: caption.bottomAnchor, left: captionContainer.leftAnchor, bottom: nil, right: captionContainer.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 130, height: 30)
     
    }
    

    func setCommentCount(_ count: Int){
        var title = "No comments"
        
        if count == 1 {
            title = "1 comment"
        }else if count > 1 {
            title = "\(count) comments"
        }
        
        commentsBtn.setTitle(title, for: .normal)
    }
    
    
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = image.frame
        
        if(contentsFrame.size.width < boundsSize.width){
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
            
        }else{
            contentsFrame.origin.x = 0
        }
        
        if(contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }
        
        image.frame = contentsFrame
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initGesture() {
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        let swipeViewUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        let swipeViewDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        swipe.direction = UISwipeGestureRecognizerDirection.up
        swipeViewUp.direction = UISwipeGestureRecognizerDirection.up
        swipeViewDown.direction = UISwipeGestureRecognizerDirection.down
        
        self.view.addGestureRecognizer(swipeViewUp)
        self.view.addGestureRecognizer(swipeViewDown)
        
        scrollView.addGestureRecognizer(swipe)
        
        
    }
    
    @objc func respondeToSwipeGesture(gesture: UIGestureRecognizer) {
        
        
        if let swipe = gesture as? UISwipeGestureRecognizer {
            
            switch swipe.direction {
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                
            case UISwipeGestureRecognizerDirection.up:
                self.dismiss(animated: true, completion: nil)
              
            default:
                break
            }
            
        }
    }
    
}
