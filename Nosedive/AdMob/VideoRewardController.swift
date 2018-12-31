//
//  VideoRewardController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/18/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension MainAppViewController:  GADRewardBasedVideoAdDelegate, UIAlertViewDelegate {
    

    func initRewardVideo(){
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self 
    }
    
    func startRewardVideo() {
        /// The reward-based video ad.
        let adRequest = GADRequest()
        adRequest.testDevices = [ "7a766ae1c50da946ad91988769b85d48" ]
        rewardBasedVideo?.load(adRequest,
                               withAdUnitID: "ca-app-pub-9751546392416390/7434825407")

        
    }
    
    // MARK: GADRewardBasedVideoAdDelegate implementation
    
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        adRequestInProgress = false
        print("Reward based video ad failed to load: \(error.localizedDescription)")
        self.view.hideLoading()
    }
    
    public func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        adRequestInProgress = false
        print("Reward based video ad is received.")
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        }
    }
    
    public func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    public func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    public func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
    }
    
    public func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        //earnCoins(NSInteger(reward.amount))
        if reward.type == "Star" {
            RatingModel().addRatingFromLacie(rating: Double(truncating: reward.amount))
        }
    }
    

}
