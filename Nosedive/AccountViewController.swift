//
//  AccountViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase
import Spring
import YPImagePicker

class AccountViewController: UIViewController {
    
    
    @IBOutlet weak var bg0: DesignableButton!
    @IBOutlet weak var bg1: DesignableButton!
    @IBOutlet weak var bg2: DesignableButton!
    @IBOutlet weak var bg3: DesignableButton!
    @IBOutlet weak var bg4: DesignableButton!
    @IBOutlet weak var bg5: DesignableButton!
    
    @IBOutlet weak var photoUser: UIImageView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: CustomTextField!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var ratingSoundSW: UISwitch!
    
    @IBOutlet weak var containerView: DesignableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFrame()
        initGesture()
        name.delegate = self
        
        self.view.backgroundColor = .clear
        name.setUserIcon()
        
        ratingSoundSW.onTintColor = UIColor(red:0.62, green:0.96, blue:0.31, alpha:1.00)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserInfo()
        
        let swState = Helpers().getSoundState()
        ratingSoundSW.setOn(swState, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func ratingSoundAction(_ sender: Any) {
      
        guard let sw = sender as? UISwitch else { return }
        
        Helpers().setSoundState(state: sw.isOn)
    }
    
    @IBAction func gotoFeedbackView(_ sender: Any) {
        let feedback = FeedbackController(collectionViewLayout: UICollectionViewFlowLayout())
        
        self.present(feedback, animated: true, completion: nil)
    }
    
    @IBAction func gotoPolicy(_ sender: Any) {
        if let url = NSURL(string: "http://nosediveapp.com/policy") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func gotoAbout(_ sender: Any) {
        
        performSegue(withIdentifier: "aboutView", sender: self)
    }
    
    
    func setupFrame(){
        photoUser.layer.cornerRadius = photoUser.frame.height / 2
        photoUser.layer.borderColor = UIColor.white.cgColor
        photoUser.layer.borderWidth = 1
        photoUser.layer.masksToBounds = true
        
        let iconCamera: UIImageView = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "photo-camera"))
            icon.frame.size = CGSize(width: photoUser.frame.width - 25, height: photoUser.frame.height - 25)
            icon.center = CGPoint(x: photoUser.frame.width/2, y: photoUser.frame.height/2)
           
            icon.contentMode = .center
            return icon
        }()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.editPhoto))
        photoUser.addGestureRecognizer(tap)
        photoUser.isUserInteractionEnabled = true
        
        photoUser.addSubview(iconCamera)
     
        
    }
    
    @objc func editPhoto(_ sender: UITapGestureRecognizer){
        
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromCamera = true
        config.onlySquareImagesFromLibrary = true
        config.showsVideoInLibrary = false
        config.usesFrontCamera = true
        
        
        let picker = YPImagePicker(configuration: config)
        let me = self
         picker.didSelectImage = { [unowned picker] img in
            
            // image picked
            self.photoUser.image = img
            picker.dismiss(animated: true, completion: nil)
            me.view.showLoading()
            
            //upload
            
            UploadFileModel().uploadFile(image: img, fileType: UploadFileModel.FileType.profile, completion: { (success, msg, fileName) in
                
                if success {
                    me.view.hideLoading()
                    self.loadUserInfo()
                }
            })
            
        }
        
        present(picker, animated: true, completion: nil)
    
    }
    
    @IBAction func bgPicker(_ sender: Any) {
        
        if let currtenBtn = sender as? DesignableButton {
            
            let buttons = [bg0, bg1, bg2, bg3, bg4]
            let bgColors = [BackgroundColor.pink, BackgroundColor.blue, BackgroundColor.black, BackgroundColor.green, BackgroundColor.red, BackgroundColor.purple]
            
            self.view.setBackgroundColor(color: bgColors[currtenBtn.tag])
            
            for btn in buttons {
                if btn?.tag != currtenBtn.tag{
                    btn?.layer.borderWidth  = 1.0
                }else{
                    btn?.layer.borderWidth = 2.5
                }
            }
        }
    }
    
    func loadUserInfo(){
        if let currentUser = Auth.auth().currentUser?.uid {
            UserModel().getUserById(uid: currentUser, completion: { (userResult) in
                if let user = userResult {
                    
                    let url = URL(string: user.photoUrl)
                    self.photoUser.kf.indicatorType = .activity
                    self.photoUser.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                    
                    self.name.text = "\(user.firstName) \(user.lastName)"
                    self.username.text = user.username
                    self.email.text = user.email
                    
                }
            })
   
        } else{
               try! Auth.auth().signOut()
            }
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
                self.dismiss(animated: true, completion: nil)
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                
                self.dismiss(animated: true, completion: nil)
                
            default:
                break
            }
        }
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        
        try! Auth.auth().signOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
        self.present(controller, animated: true, completion: nil)
    }
    
}


extension AccountViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(name.text!.count > 0){
            name.resignFirstResponder()
            let fullname = name.text!.components(separatedBy: " ")
            if fullname.count > 0 {
                guard let fistName = fullname.first else { return false }
                guard let lastName = fullname.first != fullname.last ? fullname.last : ""  else { return false }
                
                UserModel().updateUserAccount(fistName: fistName, lastName: lastName)
            }
        }
        return true
    }
    
}
