//
//  ResetPasswordViewController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/14/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Spring
import Firebase

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var viewContainer: DesignableView!
    @IBOutlet weak var emailInput: CustomTextField!
    
    @IBOutlet weak var alertMsg: UILabel!
    
    let visualEffect: UIVisualEffectView = {
       let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let ve = UIVisualEffectView(effect: effect)
        return ve
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
       self.view.insertSubview(visualEffect, at: 0)
        visualEffect.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.viewContainer.translatesAutoresizingMaskIntoConstraints = false
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.viewContainer.frame = CGRect(x: viewContainer.frame.origin.x, y: 0, width: viewContainer.frame.width, height: viewContainer.frame.height)
        viewContainer.alpha = 0
        visualEffect.alpha = 0
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        intro()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func closeView() {
        
        let animate = UIViewPropertyAnimator(duration: 0.5, curve: UIViewAnimationCurve.easeOut) {
            self.viewContainer.frame.origin = CGPoint(x: self.viewContainer.frame.origin.x, y: self.viewContainer.frame.origin.y + 200)
            self.viewContainer.alpha = 0
            self.visualEffect.alpha = 0
        }
        
        animate.addCompletion { (completion) in
            self.dismiss(animated: true, completion: nil)
        }
        
        animate.startAnimation()
    }
    
  
    func intro(){
        
        let animate = UIViewPropertyAnimator(duration: 0.5, curve: UIViewAnimationCurve.easeOut) {
            
            self.viewContainer.alpha = 1
            self.visualEffect.alpha = 1
        }
        
        animate.startAnimation()
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        closeView()
    }
    
    @IBAction func resetPasswordAction(_ sender: Any) {
        let email = emailInput.text!
        
        if email.isEmailValid() {
         
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if  error != nil {
                self.alertMsg.text = error!.localizedDescription
                self.viewContainer.animation = "shake"
                self.viewContainer.animate()
            }else{
                self.closeBtn(self)
            }
        }
        }else{
            viewContainer.animation = "shake"
            viewContainer.animate()
        }
    }
}
