//
//  RegisterViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 12/31/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Spring
import IHKeyboardAvoiding

class RegisterViewController: UIViewController {
    
    var ref: DatabaseReference!
    @IBOutlet weak var usernameInput: CustomTextField!
    @IBOutlet weak var nameInput: CustomTextField!
    @IBOutlet weak var emailInput: CustomTextField!
    @IBOutlet weak var passwordInput: CustomTextField!
    @IBOutlet weak var confirmPasswordInput: CustomTextField!
    @IBOutlet weak var alertMsg: UILabel!
    @IBOutlet weak var avoidingView: KeyboardDismissingView!
    
    var isUserAvailable: Bool = false
    var signUpModal: SignUpModel = SignUpModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         KeyboardAvoiding.avoidingView = self.avoidingView
        
        self.view.getBackgroundColor()
        
        let backgroundImage = UIImageView(image:#imageLiteral(resourceName: "selfie"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.layer.masksToBounds = true
        
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.initGesture()
        self.ref = Database.database().reference()
        
        usernameInput.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        startRegistration()
    }
    
    @IBAction func gotoPolicy(_ sender: Any) {
        if let url = NSURL(string: "http://nosediveapp.com/policy") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    func startRegistration(){
        
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        
        guard var username = usernameInput.text?.replacingOccurrences(of: " ", with: "") else { return }
        username = username.replacingOccurrences(of: "@", with: "")
        
        let form = SignUpModel.FormData(username: username, fullname: nameInput.text!, email: emailInput.text!, password: passwordInput.text!, confirmPassword: confirmPasswordInput.text!, userValid: self.isUserAvailable, fcmToken: fcmToken)
        
        let formValidation = signUpModal.validateSignUpForm(form: form)
        
        if !formValidation.0 {
            //Alert the user
            alertMsg.text = formValidation.1
        }else{
            //Regirter
            alertMsg.text = ""
            signUpModal.userRegistration(form: form, completion: { (success, msg) in
                
                if success {
                    self.gotoSignUpSecond()
                }else{
                    //TODO: Friendly MSG
                    self.alertMsg.text = msg
                }
            })
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
                self.navigationController?.popViewController(animated: true)
            case UISwipeGestureRecognizerDirection.left:
                 print("Swiped left")
                 
                self.startRegistration()
                
            default:
                break
            }
        }
    }
    
    
    func gotoSignUpSecond(){
        let registerVC:UIViewController =  (self.storyboard?.instantiateViewController(withIdentifier: "RegisterSecondViewController") as? RegisterSecondViewController)!
        
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
}


extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
           
            guard let username = usernameInput.text?.replacingOccurrences(of: " ", with: "") else { return }
            
            if !username.isEmpty {
                
            self.signUpModal.validateUserName(username:username, completion: { (isTaken, userId) in
                
                self.isUserAvailable = !isTaken
                
                self.usernameInput.toogleIcon(isError: isTaken)
            })
            }else{
               
                self.isUserAvailable = false
            }
             usernameInput.text = "@\(username)"
        }
    }
    
}
