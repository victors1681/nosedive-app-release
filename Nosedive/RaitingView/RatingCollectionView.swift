//
//  RatingCollectionView.swift
//  Nosedive
//
//  Created by Victor Santos on 4/8/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class RatingCollectionViewLayout: UICollectionViewFlowLayout {
    
    var previousOffset: CGFloat    = 0
    var currentPage: Int           = 0
    
    override func prepare() {
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            return CGPoint.zero
        }
        
        guard let itemsCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) else {
            return CGPoint.zero
        }
        
        if ((previousOffset > collectionView.contentOffset.x) && (velocity.x < 0)) {
            currentPage = max(currentPage - 1, 0)
        } else if ((previousOffset < collectionView.contentOffset.x) && (velocity.x > 0.0)) {
            currentPage = min(currentPage + 1, itemsCount - 1);
        }
        
        let itemEdgeOffset:CGFloat = (collectionView.frame.width - itemSize.width -  minimumLineSpacing * 2) / 2
        let updatedOffset: CGFloat = (itemSize.width + minimumLineSpacing) * CGFloat(currentPage) - (itemEdgeOffset + minimumLineSpacing);
        
        previousOffset = updatedOffset;
        
        return CGPoint(x: updatedOffset, y: proposedContentOffset.y);
    }
}

extension RatingMainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIViewControllerTransitioningDelegate, PhotoPostDelegate {
    
    func didTapRating(post: Post) {
        let ratingList = RatingListController(collectionViewLayout: UICollectionViewFlowLayout())
        ratingList.modalPresentationStyle = .overCurrentContext
        ratingList.post = post
        self.present(ratingList, animated: true, completion: nil)
    }
    
    
    func initCollectionView() {
        
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        layout.itemSize = CGSize(width: 242, height: 281)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = space
        
        let itemWidth = view.frame.width - space * 10 // w0 == ws
        
        layout.itemSize = CGSize(width: itemWidth, height: 180)
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 330)
        
        var attr = CustomLinearCardAttributesAnimator()
        attr.lanscape = true
        attr.scaleRate = 0.75
        attr.itemSpacing = 0.4
        
        layout.animator = attr
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.isPagingEnabled = true
        collectionView.register(RatingMainPhotoCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: CGFloat(visibleRect.midX), y: CGFloat(visibleRect.midY))
        let visibleIndexPath: IndexPath? = collectionView.indexPathForItem(at: visiblePoint)
        
        //Set Indexpath for leave rating post
        self.preventDuplicateRating(currentSelection: visibleIndexPath)
        self.currentPost = visibleIndexPath
        self.preventRatePeople(currentSelection: visibleIndexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(isSmallScreen){
            return CGSize(width: view.bounds.width, height: view.bounds.height - (view.bounds.height * 0.55))
        }
        
        return CGSize(width: view.bounds.width, height: view.bounds.height - (view.bounds.height * 0.35))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: RatingMainPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? RatingMainPhotoCell {
           
            let post = posts[safe:UInt(indexPath.item)]
            cell.post = post
            cell.delegate = self
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[safe: UInt(indexPath.item)]
        let destinationController = PhotoDisplayController()
        destinationController.post = post
        postSelected = post
        destinationController.modalPresentationStyle = .custom
        destinationController.transitioningDelegate = self
        
        guard let cellAttr = collectionView.layoutAttributesForItem(at: indexPath) else {return}
        selectedFrame = collectionView.convert(cellAttr.frame, to: collectionView.superview)
        
        
        self.present(destinationController, animated: true, completion: nil)
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let photoTransition = PhotoTransitionPresented()
        photoTransition.selectedFrame = self.selectedFrame
        photoTransition.postSelected = self.postSelected
        return photoTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let photoTransition = PhotoTransitionDismissed()
        photoTransition.selectedFrame = self.selectedFrame
        photoTransition.postSelected = self.postSelected
        return photoTransition
    }
}

