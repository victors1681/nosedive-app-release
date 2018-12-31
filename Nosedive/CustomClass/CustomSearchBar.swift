//
//  CustomSearchBar.swift
//  Nosedive
//
//  Created by Victor Santos on 1/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class CustomSearchBar: UITextField {

    private var removeView: UIImageView?
    
    override func awakeFromNib() {
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = self.frame.height / 2
        
        
        let magnifier = UIImage(named: "magnifier-search")
        let magnifierBtn = UIButton()
        magnifierBtn.setImage(magnifier, for: .normal)
        magnifierBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 17)
        magnifierBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
       
        self.leftView = magnifierBtn
        self.leftViewMode = .always
       // self.addSubview(magnifierView)
        
        
        let remove = UIImage(named: "remove-search")
        let removeBtn = UIButton()
        removeBtn.setImage(remove, for: .normal)
        removeBtn.frame = CGRect(x: self.frame.width - 25, y: 10, width: 17, height: 17)
        removeBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        self.rightView = removeBtn
        self.rightViewMode = .whileEditing
        
        
        
        
        //Button Action
        let tap = GestureProfileTap(target: self, action: #selector(self.removeText))
        removeBtn.addGestureRecognizer(tap)
        removeBtn.isUserInteractionEnabled = true
    }
    
    @objc func removeText(){
        self.text = ""
    } 

}
