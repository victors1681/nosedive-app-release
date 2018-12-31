
//  RegisterSecondViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 12/31/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import UIKit
import Spring
import YPImagePicker
import Firebase
import FirebaseStorage

class RegisterSecondViewController: UIViewController {
    
    @IBOutlet weak var bg0: DesignableButton!
    @IBOutlet weak var bg1: DesignableButton!
    @IBOutlet weak var bg2: DesignableButton!
    @IBOutlet weak var bg3: DesignableButton!
    @IBOutlet weak var bg4: DesignableButton!
    @IBOutlet weak var bg5: DesignableButton!
    @IBOutlet weak var bgContainer: SpringView!
    
    @IBOutlet weak var pictureContainer: DesignableView!
    @IBOutlet weak var profilePicture: UIImageView!
    

    let helpers = Helpers()
    var storageRef: StorageReference!
    
    var validationParameters:[String: Bool] = ["photo":false, "theme": false]
    
    var validationViews:[String: SpringView]?
    
    let backgroundImage:UIImageView  = {
        let bg = UIImageView(image:#imageLiteral(resourceName: "selfie2"))
        bg.contentMode = .scaleAspectFill
        bg.layer.masksToBounds = true
        return bg
    }()
    
    let backgroundColor: UIView = {
        let view = UIView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        
        self.view.insertSubview(backgroundColor, at: 0)
        
        backgroundColor.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        
        self.view.insertSubview(backgroundImage, at: 0)
       
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        
        self.initGesture()
        validationViews = ["photo": pictureContainer, "theme":bgContainer]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func finishRegistration(_ sender: Any) {
        self.gotoMainView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        backgroundColor.getBackgroundColor()
    }
    func initGesture()  {
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondGesture))
        
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func respondGesture(gesture:UIGestureRecognizer) {
        
        if let swipe = gesture as? UISwipeGestureRecognizer {
            switch swipe.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                self.navigationController?.popViewController(animated: true)
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
               
                self.gotoMainView()
               
            default:
                break
            }
        }
    }
    
    @IBAction func takePicture(_ sender: Any) {
        
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromCamera = true
        config.onlySquareImagesFromLibrary = true
        config.showsVideoInLibrary = false
        config.usesFrontCamera = true
        
        
        let picker = YPImagePicker(configuration: config)
        let me = self
        // unowned is Mandatory since it would create a retain cycle otherwise :)
        picker.didSelectImage = { [unowned picker] img in
            
            //Validating Photo
            self.validationParameters["photo"] =  true;
            
            // image picked
            self.profilePicture.image = img
            picker.dismiss(animated: true, completion: nil)
            me.view.showLoading()
            
           //upload
            
            UploadFileModel().uploadFile(image: img, fileType: UploadFileModel.FileType.profile, completion: { (success, msg, fileName) in
                
                if success {
                    me.view.hideLoading()
                }
            })
            
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    
    func gotoMainView(){
        if self.helpers.validateView(parameters: self.validationParameters, views: self.validationViews!) {
            
            let mainVC:UIViewController =  (self.storyboard?.instantiateViewController(withIdentifier: "MainAppViewController") as? MainAppViewController)!
            
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
    
    @IBAction func bgPicker(_ sender: Any) {
        
        self.validationParameters["theme"] =  true;
        
        
        let currtenBtn = sender as! DesignableButton
        
        let buttons = [bg0, bg1, bg2, bg3, bg4]
        
        let bgColors = [BackgroundColor.pink, BackgroundColor.blue, BackgroundColor.black, BackgroundColor.green, BackgroundColor.red, BackgroundColor.purple]
        
        self.backgroundColor.setBackgroundColor(color: bgColors[currtenBtn.tag])
        
        for btn in buttons {
            if btn?.tag != currtenBtn.tag{
                btn?.layer.borderWidth  = 1.0
            }else{
                btn?.layer.borderWidth = 2.5
            }
        }
    }
}

