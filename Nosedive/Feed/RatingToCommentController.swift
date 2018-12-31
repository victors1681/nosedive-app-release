//
//  RatingToCommentController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/29/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

class RatingToCommentController: UIViewController, UIGestureRecognizerDelegate {
    
    var post: Post?
    let ratingModel = RatingModel()
    var swipeControl = false
    var cell: FeedPostCell?
    
    let isSmallScreen : Bool = {
        let size =  Device.IS_4_INCHES_OR_SMALLER()
        return size
    }()
    
    let cosmosView: CosmosView = {
        let cosmos = CosmosView()
        cosmos.settings.starSize = 60
        cosmos.settings.filledColor = UIColor(red:1.00, green:0.98, blue:0.21, alpha:1.00)
        cosmos.settings.emptyColor = UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.filledBorderColor = .clear
        cosmos.settings.emptyBorderColor =  UIColor(red:1.00, green:1, blue:1, alpha:0.36)
        cosmos.settings.fillMode = .half
        cosmos.settings.starMargin = 15
        cosmos.settings.updateOnTouch = true
        
        return cosmos
    }()
    
    let helpText: UILabel = {
       let label = UILabel()
        label.text = "select and swipe up"
        label.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.6)
        label.font = UIFont(name: "AvenirNext-Reguar", size: 15)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        setupView()
        initSwipe()
        getBackgroundColor()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        guard let p = post else { return }
        
        if p.hasFace {
            cosmosView.settings.totalStars = 1
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupView(){
        
        view.addSubview(cosmosView)
        
        let cosmosStarSize: Double = isSmallScreen ? 40 : 60
        cosmosView.settings.starSize = cosmosStarSize
        
        cosmosView.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 90, paddingRight: 20, width: 0, height: 0)
        cosmosView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cosmosView.contentMode = .scaleAspectFit
        cosmosView.rating = 0
        
        view.addSubview(helpText)

        helpText.anchor(top: nil, left: nil, bottom: cosmosView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: 0, height: 0)
        helpText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func initSwipe() {
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        let swipeView = UISwipeGestureRecognizer(target: self, action: #selector(self.respondeToSwipeGesture))
        
        swipe.direction = UISwipeGestureRecognizerDirection.up
        swipeView.direction = UISwipeGestureRecognizerDirection.down
        
        self.view.addGestureRecognizer(swipeView)
        cosmosView.addGestureRecognizer(swipe)
        
    }
    
    @objc func respondeToSwipeGesture(gesture: UIGestureRecognizer) {
        
        var vote = cosmosView.rating
        
        if Int(vote) == 0 { return }
        
        if let swipe = gesture as? UISwipeGestureRecognizer {
            
            switch swipe.direction {
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                
            case UISwipeGestureRecognizerDirection.up:
                
                guard let p  = self.post else { return }
                if p.hasRated != 0.0 && cell?.starBtn.imageView?.image == #imageLiteral(resourceName: "star-empty"){
                    
                    ratingModel.evaluateRating(RatingNumber: vote)
                    ratingModel.restartRating(ratingView: cosmosView)
                    
                    //Post Vote
                    
                    if p.hasFace {
                        vote = 5
                    }
                    
                    
                    guard let userId = p.user?.id else { return }
                    
                    var observeId:UInt = 0
                    var ref: DatabaseReference = Database.database().reference()
                    
                    (observeId, ref) = ratingModel.ratingUpdatePostObserve(postId: p.postId, completion: { (rating, votes, indexPath) in
                        
                        if let r = rating {
                           self.cell?.setPostRating(rating: r)
                        }
                        if let v = votes {
                             self.cell?.setRatingVote(v)
                        }
                       
                        ref.removeObserver(withHandle: observeId)
                        
                    })
                    
                    ratingModel.addPostRating(rating: vote, DestinationUser: userId, postId: p.postId)
                    
                    if let cell = self.cell {
                        cell.setStateToStarBtn(true)
                    }
                    
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    print("You has rated this post")
                    let alert = UIAlertController(title: "🙃", message: "You already rated this post!", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(action)
                    
                    
                    self.present(alert, animated: true)
                }
                
                
            default:
                break
            }
            
        }
    }
    
    
    func getBackgroundColor(){
        
        
        let (topColor, bottomColor) = Background().colorSelector(color: BackgroundColor.baseBlack, alpha: 0.8)
        
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations = [0.0,0.8,1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = gradientLocations as [NSNumber]
        
        gradientLayer.frame = self.view.bounds
        
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
}
