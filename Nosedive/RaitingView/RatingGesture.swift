//
//  RatingGesture.swift
//  Nosedive
//
//  Created by Victor Santos on 4/7/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Firebase

extension RatingMainViewController {
    
    func initGesture() {
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        let swipeViewUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        let swipeViewDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        swipe.direction = UISwipeGestureRecognizerDirection.up
        swipeViewUp.direction = UISwipeGestureRecognizerDirection.up
        swipeViewDown.direction = UISwipeGestureRecognizerDirection.down
        
        self.view.addGestureRecognizer(swipeViewUp)
        self.view.addGestureRecognizer(swipeViewDown)
        
        cosmosView.addGestureRecognizer(swipe)
        
        
    }
    
    
    
    @objc func respondeToSwipeGesture(gesture: UIGestureRecognizer) {
        
        
        if let swipe = gesture as? UISwipeGestureRecognizer {
            
            switch swipe.direction {
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                
            case UISwipeGestureRecognizerDirection.up:
                if(animationTimer != nil ) {return}
                var vote = cosmosView.rating
                if Int(vote) == 0 {  self.animationHelper(); return }
                
                
                
                //ratingModel.restartRating(ratingView: cosmosView)
                
                //Post Vote
                
                guard let postIndexPath = self.currentPost else { return }
                
                
                guard let userId = userData?.id else { return }
                guard let post = posts[safe: UInt(postIndexPath.item)] else { return }
                
                if post.hasFace {
                    vote = 5
                }
                
                ratingModel.evaluateRating(RatingNumber: vote)
                print("Swipe Detected", vote)
                
                //Opserve rating per post and update
                var observeId:UInt = 0
                var ref: DatabaseReference = Database.database().reference()
                
                //Disable Rating vote after leave the first one
                if let cell: RatingMainPhotoCell = self.collectionView.cellForItem(at: postIndexPath) as? RatingMainPhotoCell{
                    
                    cell.hasRated = vote
                    cell.setPostRating(rating: Double(post.votes) + 1)
                }
                self.disableCosmos(rating: vote)
                ////////////////
                
                (observeId, ref) = ratingModel.ratingUpdatePostObserve(postId: post.postId, indexPath: postIndexPath, completion: { (rating, votes, currentIndexPath) in
                    
                    guard let indexPath: IndexPath = currentIndexPath else { return }
                    
                    
                    if let cell: RatingMainPhotoCell = self.collectionView.cellForItem(at: indexPath) as? RatingMainPhotoCell{
                        
                        if let v = votes {
                            if cell.isFace {
                                cell.setPostRating(rating: Double(v))
                            }
                        }
                        if let r = rating {
                            if !cell.isFace{
                                cell.setPostRating(rating: r)
                            }
                        }
                        
                    }
                    ref.removeObserver(withHandle: observeId)
                    
                })
                
                //ratingModel.addRating(rating: vote, DestinationUser: userData!.id)
                ratingModel.addPostRating(rating: vote, DestinationUser: userId, postId: post.postId)
                didRate = true
                
                
            default:
                break
            }
            
        }
    }
}
