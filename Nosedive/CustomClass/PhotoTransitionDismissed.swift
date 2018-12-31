//
//  CustomAnimator.swift
//  CustomNavigationAnimations-Starter
//
//  Created by Victor Santos on 2/22/18.
//  Copyright © 2018 Sam Stone. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoTransitionDismissed: NSObject, UIViewControllerAnimatedTransitioning {
    
    var selectedFrame: CGRect?
    var postSelected: Post? {
        didSet {
            guard let post = postSelected else {return}
            
            let url = URL(string: post.imageUrl)
            imageView.kf.setImage(with: url)
        }
    }
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.layer.masksToBounds = true
        return img
    }()
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from) else {return}
        guard let selectedFrame = selectedFrame else {return}
      
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            fromView.frame = selectedFrame
            fromView.alpha = 0
            fromView.layoutIfNeeded()
           
        }) { (success) in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}


