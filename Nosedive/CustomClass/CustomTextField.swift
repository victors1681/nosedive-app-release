//
//  CustomField.swift
//  Nosedive
//
//  Created by Victor Santos on 1/14/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    var bottomBorder = UIView()
    var borderColor: UIColor = UIColor.white
    var errorColor: UIColor = UIColor(red:0.94, green:0.35, blue:0.38, alpha:1.00)
    var errorIcon: UIImageView?
    var sucessIcon: UIImageView?
    
    override func awakeFromNib() {
    
        let iconOrigin = CGPoint(x: self.frame.width - 15, y: (self.frame.height / 2) - 5)
        
        let image = UIImage(named: "danger")
        let imageView = UIImageView(image: image)
        imageView.frame.origin = iconOrigin
        errorIcon = imageView
        
        let imageSuccess = UIImage(named: "success")
        let imageViewSuccess = UIImageView(image: imageSuccess)
        imageViewSuccess.frame.origin = iconOrigin
        sucessIcon = imageViewSuccess
        
       
        let frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 0.7)
        bottomBorder = UIView(frame: frame)
        bottomBorder.backgroundColor = borderColor
        
        self.borderStyle = .none
        let placeholder = self.placeholder
        self.attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSAttributedStringKey.foregroundColor : borderColor])

        addSubview(bottomBorder)
        bottomBorder.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.7)

    }
    
    func setUserIcon(){
        let magnifier = UIImage(named: "user-field-icon")
        let btn = UIButton()
        btn.setImage(magnifier, for: .normal)
        btn.frame = CGRect(x: self.frame.width - 25, y: 10, width: 17, height: 17)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        
        self.rightView = btn
        self.rightViewMode = .always
    }
    
    func setErrorStyle(){
        self.bottomBorder.backgroundColor = self.errorColor
    }
    
    func setNormalStyle(){
         self.bottomBorder.backgroundColor = self.borderColor
    }
    
   private func showAlertIcon(){
        self.addSubview(errorIcon!)
    }
    
   private func hideAlertIcon(){
        self.errorIcon!.removeFromSuperview()
    }
    
   private func showSuccessIcon(){
        self.addSubview(sucessIcon!)
    }
    
    private func hideSuccessIcon() {
        self.sucessIcon?.removeFromSuperview()
    }
    
   
    func toogleIcon(isError: Bool) {
        
        if(isError){
            showAlertIcon()
            hideSuccessIcon()
        }else{
            hideAlertIcon()
            showSuccessIcon()
        }
        
    }
    

}
