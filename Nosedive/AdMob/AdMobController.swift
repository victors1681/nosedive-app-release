//
//  AdMobController.swift
//  Nosedive
//
//  Created by Victor Santos on 2/18/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import GoogleMobileAds


extension FeedViewController: GADBannerViewDelegate {
    
    // MARK: - GADBannerView delegate methods
    
    func adViewDidReceiveAd(_ adView: GADBannerView) {
        // Mark banner ad as succesfully loaded.
        loadStateForAds[adView] = true
        // Load the next ad in the adsToLoad list.
        preloadNextAd()
    }
    
    func adView(_ adView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed to receive ad: \(error.localizedDescription)")
        // Load the next ad in the adsToLoad list.
        preloadNextAd()
    }
    
    // MARK: - UITableView source data generation
    
    /// Adds banner ads to the tableViewItems list.
    func addBannerAds() {
        var index = adInterval
        // Ensure subview layout has been performed before accessing subview sizes.
        //tableView.layoutIfNeeded()
        collectionView?.layoutIfNeeded()
        
        while index < posts.count {
            if let _ = posts[safe: UInt(index)] as? GADBannerView {
                posts.remove(at: index)
            }
            let adSize = GADAdSizeFromCGSize(
                CGSize(width: (collectionView?.contentSize.width)!, height: adViewHeight))
            let adView = GADBannerView(adSize: adSize)
            adView.adUnitID = adUnitID
            adView.rootViewController = self
            adView.delegate = self
            
            posts.insert(adView, at: index)
            adsToLoad.append(adView)
            loadStateForAds[adView] = false
            
            index += adInterval
        }
    }
    
    /// Preload banner ads sequentially. Dequeue and load next ad from `adsToLoad` list.
    func preloadNextAd() {
        if !adsToLoad.isEmpty {
            let ad = adsToLoad.removeFirst()
            let adRequest = GADRequest()
            //adRequest.testDevices = [ kGADSimulatorID ]
            adRequest.testDevices = [ "7a766ae1c50da946ad91988769b85d48" ]
            ad.load(adRequest)
        }
    }
    
    
}
