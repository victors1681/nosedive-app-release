//
//  CustomAnimator.swift
//  CustomNavigationAnimations-Starter
//
//  Created by Victor Santos on 2/22/18.
//  Copyright © 2018 Sam Stone. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoTransitionPresented: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else {return}
        
        guard let selectedFrame = selectedFrame else {return}
        imageView.frame = selectedFrame
        containerView.addSubview(imageView)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            
            self.imageView.frame = toView.frame
            
        }) { (success) in
            containerView.addSubview(toView)
            self.imageView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}

