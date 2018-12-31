//
//  SharePhotoViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/20/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import FacebookShare
import IHKeyboardAvoiding
import CoreImage

class SharePhotoViewController: UIViewController {

    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var facebookShare: UISwitch!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var avoidingView: KeyboardDismissingView!
    @IBOutlet weak var facesLabel: UILabel!
    
    let placeholcer: String = "add some comments"
    
    var selectedImage: PhotoImageType? {
        didSet {
            //handling rotation
            guard let photoImage = selectedImage  else { return }
            guard let cgImage = photoImage.image.cgImage else {  print("Error generating CGImage"); return }
            
            if photoImage.deviceOrientation == UIDeviceOrientation.landscapeRight {
                selectedImage?.image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right )
            }else if photoImage.deviceOrientation == UIDeviceOrientation.landscapeLeft {
                selectedImage?.image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .left )
            }
            
            self.detectFaces(image: photoImage.image)
        }
    }
    
    static let updateFeedNotificationName = Notification.Name("UpdateFeed")
    
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "left-arrow"), for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return btn
    }()
    
    lazy var shareBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("share", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        return btn
    }()

    
    var faces: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facesLabel.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
       
        textview.delegate = self
        photoImageView.image = selectedImage?.image
        
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    
        self.title = "Share Photo"
        self.view.backgroundColor = .clear
        
        textview.text = placeholcer
        textview.textColor = UIColor.darkGray
        
        setupLayout()
        KeyboardAvoiding.avoidingView = self.avoidingView
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        if(self.faces > 0) {
            if self.faces == 1 {
                self.facesLabel.text = "1 person detected"
            }else{
                self.facesLabel.text = "\(faces) people detected"
            }
            self.facesLabel.isHidden = false
        }
    }
    
    func detectFaces(image: UIImage) {
        let faceImage = CIImage(image: image)
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let faces = faceDetector?.features(in: faceImage!) as! [CIFaceFeature]
        print("Number of faces: \(faces.count)")

        self.faces = faces.count
        
    }
    
    
    func setupLayout(){
        
        photoImageView.layer.borderWidth = 1
        photoImageView.layer.borderColor = UIColor.white.cgColor
        photoImageView.layer.cornerRadius = 3
        photoImageView.contentMode = .scaleAspectFit
        textview.layer.borderColor = UIColor.white.cgColor
        textview.layer.cornerRadius = 3
        textview.layer.borderWidth = 1
        
        
        
        let image = selectedImage?.image
        let bgImage = UIImageView(image: image)
        bgImage.contentMode = .scaleAspectFill
        bgImage.layer.masksToBounds = true
        
        view.insertSubview(bgImage, at: 0)
        
        bgImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func handleBack(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShare() {
        
        //share on facebook
        if facebookShare.isOn {
            guard let image = photoImageView.image else { return }
            sharePhotoOnFacebook(caption: textview.text, image: image)
        }
        self.view.showLoading()
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let upload = UploadFileModel()
        guard let selectedImage = selectedImage?.image else { return }
        
        upload.uploadFile(image: selectedImage, fileType: .post) { (success, path, fileName) in
         
            if success {
                //Save post Info
                guard (self.selectedImage != nil) else{
                    return
                }
                
                 let height = selectedImage.size.height
                 let width = selectedImage.size.width
                let caption = self.textview.text!
             
                
                PostFRController().writeNewPost(withCaption: caption, imageWidth: width, imageHeight: height, imageUrl: path, fileName: fileName, faces: self.faces)
                
                
                self.performSegue(withIdentifier: "FeedView", sender: nil)
                NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
                
            }
            
            self.view.hideLoading()
        }
    }


}


extension SharePhotoViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textview.text!.count > 0 && textView.text != placeholcer {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == placeholcer)
        {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty
        {
            textView.text = placeholcer
            textView.textColor = UIColor.darkGray
        }
        textView.resignFirstResponder()
    }
}
