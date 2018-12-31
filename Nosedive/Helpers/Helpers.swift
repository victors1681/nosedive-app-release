//
//  Helpers.swift
//  Nosedive
//
//  Created by Victor Santos on 12/31/17.
//  Copyright © 2017 itsoluclick. All rights reserved.
//

import Foundation
import UIKit
import Spring

enum BackgroundColor:String {
    case pink, blue, black, green, red, purple, baseBlack
}

class Helpers {
    
 
    func validateView(parameters: [String: Bool], views: [String: SpringView])->Bool {
        
        var index = 0
        for (key, _) in parameters {
            if !parameters[key]! {
                
                guard let view:SpringView = views[key] else{
                    return false
                }
                
                view.animation = "shake"
                view.animate()
                return false
            }
            index += 1;
        }
        
        return true
    }
    
    
    func getSafeAreaSize()->(top: CGFloat, bottom: CGFloat){
        
        guard let rootView = UIApplication.shared.keyWindow else { return (0,0) }
        
        if #available(iOS 11.0, *) {
            
            let bottomInset = rootView.safeAreaInsets.bottom
            let top = rootView.safeAreaInsets.top
            
            return  (top, bottomInset)
            
        } else {
            
            return (40, 0)
            
        }
    }
    
    func getSoundState()->Bool{
        let udefault = UserDefaults.standard
        
       let sound = udefault.object(forKey: "ratingSound") as? Bool ?? true
       
        return sound
    }
    
    func setSoundState(state: Bool) {
        let udefault = UserDefaults.standard
        udefault.set(state, forKey: "ratingSound")
    }
    
    func getInitialNotification()->Bool{
        let udefault = UserDefaults.standard
        
        let ini = udefault.object(forKey: "iniNotification") as? Bool ?? true
        
        return ini
    }
    
    func setInitialNotification(state: Bool) {
        let udefault = UserDefaults.standard
        udefault.set(state, forKey: "iniNotification")
    }
    
}

