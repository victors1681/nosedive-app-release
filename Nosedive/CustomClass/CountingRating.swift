//
//  CounterAnimation.swift
//  Nosedive
//
//  Created by Victor Santos on 1/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//
import UIKit
import Spring

class CountingRating: SpringLabel {
    
    enum CounterAnimationType {
        case Linear  // f(x) = x
        case EaseIn  // f(x) = x^3
        case EaseOut // f(x) = (1-x)^3
    }
    
    enum CounterType {
        case Int
        case Float
    }
    
    let counterVelocity: Float = 3.0
    
    var startNumber: Float = 0.0
    var endNumber: Float = 0.0
    
    var progress: TimeInterval!
    var durationCounter: TimeInterval!
    var lastUpdate: TimeInterval!
    
    var counterAnimationType: CounterAnimationType!
    var counterType: CounterType!
    
    var timer: Timer?
    
    var animationInProgress = false
    
    var currentCounterValue: Float{
        if progress >= durationCounter {
            return endNumber
        }
        
        let percentage = Float(progress / durationCounter)
        let update = updateCounter(counterValue: percentage)
        
        return startNumber + (update * (endNumber - startNumber))
    }
    
    func count(fromValue: Float, toValue: Float, withDuration duration:TimeInterval, andAnimationType animationType: CounterAnimationType, andCounterType counterType: CounterType) {
        
        self.startNumber = fromValue
        self.endNumber = toValue
        self.durationCounter = duration
        self.counterType = counterType
        self.counterAnimationType = animationType
        
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        invalidateTimer()
        
        if duration == 0 {
            updateText(value: toValue)
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(CountingRating.updateValue), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= durationCounter {
            invalidateTimer()
            progress = durationCounter
        }
        
        if(!animationInProgress){
            updateText(value: currentCounterValue)
            // animationInProgress = true;
        }
    }
    
    func invalidateTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func updateText(value: Float){
        
        
        switch counterType! {
        case .Int:
            self.text = "\(Int(value))"
        case .Float:
            self.text = String(format: "%.2f", value)
        }
        
    }
    
    func updateCounter(counterValue: Float)->Float {
        
        switch counterAnimationType! {
        case .Linear:
            return counterValue
        case .EaseIn:
            return powf(counterValue, counterVelocity)
        case .EaseOut:
            return 1.0 - powf(1.0 - counterValue, counterVelocity)
        }
    }
    
  
}
