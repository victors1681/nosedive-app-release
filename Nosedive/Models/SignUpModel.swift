//
//  SignUpModel.swift
//  Nosedive
//
//  Created by Victor Santos on 1/14/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class SignUpModel {
    
    struct FormData {
        var username: String
        var fullname: String
        var email: String
        var password: String
        var confirmPassword: String
        var userValid: Bool
        var fcmToken: String
    }
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference().child("usernames")
    }
    
    func userRegistration(form: FormData, completion: @escaping (Bool, String)->()){
        
        Auth.auth().createUser(withEmail: form.email, password: form.password) { (user, error) in
            
            if error != nil {
                //self.showMessagePrompt(error.localizedDescription)
                completion(false, (error?.localizedDescription)!)
                return
            }
                         
            let fullname = form.fullname.components(separatedBy: " ")
            guard let fistName = fullname.first else { return }
            guard let lastName = fullname.first != fullname.last ? fullname.last : ""  else { return }
            
            print("Successfully created user:", user?.uid ?? "")
            
            guard let uid = user?.uid else { return }
            
            UserModel().storeUser(newUid: uid, username: form.username, fullname: form.fullname, firstName: fistName, lastName: lastName, email: form.email, fcmToken: form.fcmToken)
            
            completion(true, "")
            
        }
        
    }
    
    func validateSignUpForm(form: FormData)->(Bool, String){
        
        //validate Username
        if !form.userValid {
            return (false, "Please enter a valid username")
        }
        //Validate name
        
        if form.fullname.isEmpty {
            return (false, "Please enter your full name")
        }
    
        //validate email
        if !form.email.isEmailValid() {
            return(false, "Invalid Email")
        }
        
        //validate password
        let passwordValidation = confirmPassword(password: form.password, confirmPassword: form.confirmPassword)
        if !passwordValidation.0 {
            return (false, passwordValidation.1)
        }
        
        return (true, "")
        
    }
    
    func validateUserName(username: String, completion: @escaping (_ isTaken: Bool, _ userId: String)->()){
        
        ref.child(username.lowercased()).observeSingleEvent(of: DataEventType.value) { (snap) in
            if let username =  JSON(snap.value ?? "").string {
                 completion(true, username)
            }else{
            completion(false, "")
        }
        }
        
    }
    
    func confirmPassword(password: String, confirmPassword: String) -> (Bool, String) {
        
        if password != confirmPassword {
            return (false, "password and confirm are different")
        }
        
        if password.count < 6 {
            return (false, "password must be greater than 6")
        }
        
        if (password == "123456"
            && password == "1234567"
            && password == "1234568"
            && password == "abcdef"
            && password == "asdfgh"
            && password == "1234567") {
            
            return (false, "please try a better password")
        }
        
         return (true, "")
    }
    
}
