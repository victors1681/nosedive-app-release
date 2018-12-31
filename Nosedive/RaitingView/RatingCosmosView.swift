//
//  RatingCosmosView.swift
//  Nosedive
//
//  Created by Victor Santos on 4/7/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

extension RatingMainViewController {
    //MARK: TUTORIAL ANIMATION
    
    func initCosmos(){
        cosmosView.settings.fillMode = .half
        cosmosView.contentMode = .scaleAspectFit
        cosmosView.layer.masksToBounds = true
        cosmosView.rating = 0
        
        cosmosView.didTouchCosmos = { rating in
            if(self.cosmosView.settings.updateOnTouch){
                self.ratingModel.vibrationIntensity(rating: rating)
            }
        }
        
    }
    
    func evaluateFistPost(){
        guard let post = posts[safe: UInt(0)] else { return }
        
        self.hasFaces(post.hasFace)
        
        if post.hasRated > 0 {
            self.disableCosmos(rating: post.hasRated)
        }else{
            self.cosmosView.settings.updateOnTouch = true;
            self.cosmosView.alpha = 1
        }
    }
    
    func disableCosmos(rating: Double){
        if(rating > 0){
        self.cosmosView.rating = rating
        self.cosmosView.settings.updateOnTouch = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.cosmosView.alpha = 0.4
        }, completion: nil)
        
        }else{
            self.cosmosView.rating = 0
            self.cosmosView.settings.updateOnTouch = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.cosmosView.alpha = 1
            }, completion: nil)
            
        }
    }
    
    func preventDuplicateRating(currentSelection: IndexPath?){
        guard let currentIndex = currentSelection else { return }
        
            guard let post = posts[safe: UInt(currentIndex.item)] else { return }
            
            if let cell: RatingMainPhotoCell = self.collectionView.cellForItem(at: currentIndex) as? RatingMainPhotoCell{
                
                if cell.hasRated > 0.0 {
                    //Check if user leaved rating recently to the post
                     self.disableCosmos(rating: cell.hasRated)
                }else{
                     self.disableCosmos(rating: post.hasRated)
                }
            }
        
    }
    
    func preventRatePeople(currentSelection: IndexPath?){
        guard let currentIndex = currentSelection else { return }
        
        if let cell: RatingMainPhotoCell = self.collectionView.cellForItem(at: currentIndex) as? RatingMainPhotoCell{
            
            self.hasFaces(cell.isFace)
        }
        
    }
    
    func animationHelper(){
        helpText.animation = "shake"
        helpText.animate()
        
        if(animationTimer == nil){
            animationTimer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(animateStar), userInfo: nil, repeats: true)
        }
    }
    
   
    @objc func animateStar(){
        if(starTest < 5.0) {
            self.cosmosView.rating = Double(starTest)
            starTest += 0.5
        }else{
            animationTimer?.invalidate()
            animationTimer = nil
            animationTimer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(animateStarOut), userInfo: nil, repeats: true)
        }
    }
    
    @objc func animateStarOut(){
        
        if(starTest > 0){
            starTest -= 0.5
            self.cosmosView.rating = Double(starTest)
        }else{
            animationTimer?.invalidate()
            animationTimer = nil
            starTest = 0.0
        }
    }
    
    
    
}
