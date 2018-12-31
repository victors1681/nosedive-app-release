//
//  TransitioningToRating.swift
//  Nosedive
//
//  Created by Victor Santos on 4/15/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//
import UIKit

extension FeedViewController: CircularTransitionDelegate, UIViewControllerTransitioningDelegate {
    func transitionDismissCallBack(controller: CircularTransition) {
         //noting happens after close ratingMainViewController
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.transitionMode = .present
        transition.circleColor = .clear
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        
        return transition
    }
    
}
