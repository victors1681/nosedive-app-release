//
//  ViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 12/30/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import UIKit
import Firebase
import Spring
import AVFoundation
import IHKeyboardAvoiding

class LoginViewController: UIViewController {
    @IBOutlet weak var forgotPasswordBtn: UIButton!
 
    
    @IBOutlet weak var avoidingView: UIView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var newAccountBtn: CustomUIButton!
    @IBOutlet weak var loginBtn: CustomUIButton!
    @IBOutlet weak var emailText: CustomTextField!
    @IBOutlet weak var passwordText: CustomTextField!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var alertMsg: UILabel!
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KeyboardAvoiding.avoidingView = self.avoidingView
        
        emailText.delegate = self
        passwordText.delegate = self
        
        self.initSwipe()
        self.view.getBackgroundColor(alpha: 0.8)
        self.view.layer.masksToBounds = true
        
        self.intro()
        
        alertMsg.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
                //Update token
               UserModel().updateFcmToken()
               self.gotoMainApp()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        self.performSegue(withIdentifier: "resetPassword", sender: nil)
    }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        self.startAutentication()
        self.hideKeyboard()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        self.gotoSignUp()
        self.hideKeyboard()
    }
    
    func hideKeyboard(){
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
    }
    
 
    
    /*
     Method to log in use from return on the keyboard button and login button
     */
    
    func startAutentication(){
        let e = emailText.text!
        let p = passwordText.text!
        
        
        if(!e.isEmpty && !p.isEmpty){
            if emailText.text!.isEmailValid() {
                self.authentication(email: e, password: p)
            }else{
                alertMsg.text = "invalid email"
            }
        }else{
            emailText.setErrorStyle()
            passwordText.setErrorStyle()
        }
        
    }
    
    
    func initSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        swipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipe)
    }
    
    func intro(){
        let resource = Bundle.main.url(forResource: "girl-original", withExtension: "mp4")
        
        player = AVPlayer(url: resource!)
        let playerLayer = AVPlayerLayer(player: player!)
        playerLayer.videoGravity = .resizeAspectFill
        
        
        playerLayer.frame = self.view.layer.frame
        player?.actionAtItemEnd = .none
        
        
        player?.play()
        self.view.layer.insertSublayer(playerLayer, at: 0)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.loopVideo),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
    }
    
    @objc func loopVideo(){
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    
    @objc func respondeToSwipeGesture() {
        
        let email = emailText.text!
        let password = passwordText.text!
        
        if (email.isEmpty && password.isEmpty) {
            self.gotoSignUp()
        }else{
            //Login
            print("Login")
            self.authentication(email: email, password: password)
        }
        
    }
    
    func authentication(email: String, password: String){
        
        self.view.showLoading()
        let me = self
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                me.view.hideLoading()
                print("Login Error ", error)
                self.alertMsg.text = "user or password is incorrect"
                return
            }
            me.view.hideLoading()
            print("Login sussesfully")
            
            //Update token
            UserModel().updateFcmToken()
            
            self.gotoMainApp()
            self.hideKeyboard()
        }
        
    }
    
    func gotoMainApp(){
        let registerVC:UIViewController =  (self.storyboard?.instantiateViewController(withIdentifier: "MainAppViewController") as? MainAppViewController)!
        
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    func gotoSignUp(){
        let registerVC:UIViewController =  (self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController)!
        
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            if !emailText.text!.isEmpty {
                passwordText.becomeFirstResponder()
            }
        }else{
            self.startAutentication()
            passwordText.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        alertMsg.text = ""
        passwordText.setNormalStyle()
        emailText.setNormalStyle()
    }
    
}



