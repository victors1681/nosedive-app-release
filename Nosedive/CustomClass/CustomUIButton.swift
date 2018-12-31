//
//  CustomUIButton.swift
//  Nosedive
//
//  Created by Victor Santos on 1/14/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class CustomUIButton: UIButton {

    override func awakeFromNib() {
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.8
        self.tintColor = UIColor.white
        self.frame.size = CGSize(width: self.frame.width, height: 45)
        self.layer.cornerRadius = self.frame.height / 2
        
        self.titleLabel?.font = UIFont(name: "Avenir Next Regular", size: 18)
        
    }

}
