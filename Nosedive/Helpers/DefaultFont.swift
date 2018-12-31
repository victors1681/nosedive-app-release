//
//  DefaultFont.swift
//  Nosedive
//
//  Created by Victor Santos on 4/7/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

enum DefaultFont: String {
    
    case regular = "AvenirNext-Regular"
    case demiBold = "AvenirNext-DemiBold"
    case medium = "AvenirNext-Medium"
    case italic = "AvenirNext-Italic"
    case ultraLight = "AvenirNext-UltraLight"
    
    func size(_ size: CGFloat ) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
    
}
