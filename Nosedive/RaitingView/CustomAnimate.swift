//
//  CustomAnimate.swift
//  Nosedive
//
//  Created by Victor Santos on 4/9/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

/// An animator that turns the cells into card mode.
/// - warning: You need to set `clipsToBounds` to `false` on the cell to make
/// this effective.
public struct CustomLinearCardAttributesAnimator: LayoutAttributesAnimator {
    /// The alpha to apply on the cells that are away from the center. Should be
    /// in range [0, 1]. 0.5 by default.
    public var minAlpha: CGFloat
    
    /// The spacing ratio between two cells. 0.4 by default.
    public var itemSpacing: CGFloat
    
    /// The scale rate that will applied to the cells to make it into a card.
    public var scaleRate: CGFloat
    
    public var lanscape: Bool = false

    
    public init(minAlpha: CGFloat = 0.5, itemSpacing: CGFloat = 0.4, scaleRate: CGFloat = 0.7) {
        self.minAlpha = minAlpha
        self.itemSpacing = itemSpacing
        self.scaleRate = scaleRate
    }
    
    public func animate(collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes) {
        //let position = attributes.middleOffset
        let distance = collectionView.frame.width
        let itemOffset = attributes.center.x - collectionView.contentOffset.x
        
        let middleOffset = itemOffset / distance - 0.5
        
        let position = middleOffset
        let scaleFactor = scaleRate - 0.1 * abs(position)
        let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
        let translationTransform: CGAffineTransform
        
        if attributes.scrollDirection == .horizontal {
            let width = collectionView.frame.width
            let translationX = -(width * itemSpacing * position)
            translationTransform = CGAffineTransform(translationX: translationX, y: 0)
        } else {
            let height = collectionView.frame.height
            let translationY = -(height * itemSpacing * position)
            translationTransform = CGAffineTransform(translationX: 0, y: translationY)
        }
        
        attributes.alpha = 1.0 - abs(position) + minAlpha
        attributes.transform = translationTransform.concatenating(scaleTransform)
    }
}
