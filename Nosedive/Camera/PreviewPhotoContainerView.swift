//
//  PreviewPhotoContainerView.swift
//  Nosedive
//
//  Created by Victor Santos on 1/26/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Photos

protocol PreviewPhotoContainerViewDelegate {
    func goToShare(image: PhotoImageType)
}

class PreviewPhotoContainerView: UIView {
    
    var delegate: PreviewPhotoContainerViewDelegate?
    
    private var previewImageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    var photoImageType : PhotoImageType? {
        didSet{
            guard let photo = photoImageType else { return }
            previewImageView.image = photo.image
        }
    }
    
    let cancelButton: UIButton = {
       let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "close-button-shadow"), for: .normal)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    
    let savePhoto: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "save-photo"), for: .normal)
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return btn
    }()
    
    let nextBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "right-arrow-shadow"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleCancel(){
        self.removeFromSuperview()
    }
    
    @objc func handleNext(){
     
        guard let photoImage =  photoImageType else { return }
        self.delegate?.goToShare(image: photoImage)
    }
    
    @objc func handleSave(){
        
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            
            guard let previewImage = self.previewImageView.image else { return }
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
        }) { (success, err) in
            if let err = err {
                print("Failed to save image to photo library", err)
                return
            }
        }
        
        DispatchQueue.main.async {
            let saveLabel = UILabel()
            saveLabel.text = "Saved Successfully"
            saveLabel.font = UIFont.boldSystemFont(ofSize: 18)
            saveLabel.textColor = .white
            saveLabel.textAlignment = .center
            saveLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
            saveLabel.numberOfLines = 0
            
            self.addSubview(saveLabel)
            saveLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
            saveLabel.center  = self.center
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                
                saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: { (completed) in
                
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    saveLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    saveLabel.alpha = 0
                }, completion: { (_) in
                    saveLabel.removeFromSuperview()
                })
            })
        }
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        self.addSubview(savePhoto)
        savePhoto.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 12, paddingRight: 0, width: 50, height: 50)
        
        
        self.addSubview(nextBtn)
        nextBtn.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
