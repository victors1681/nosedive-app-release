//
//  Sounds.swift
//  Nosedive
//
//  Created by Victor Santos on 1/12/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import AVFoundation

var player: AVAudioPlayer?

class SoundEffects {

enum RatingSound: String {
    case oneStar = "1_star"
    case twoStars = "2_stars"
    case threeStars = "3_stars"
    case fourStars = "4_stars"
    case fiveStars = "5_stars"
}
    

func playRatingSound(ratingSound sound: RatingSound) {
    
    if !Helpers().getSoundState() {
        print("Sound Disabled!")
        return
    }
    
    guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Url is Nill, sound no executed")
            return
        
    }
    
    do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        try AVAudioSession.sharedInstance().setActive(true)
        
        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        
        /* iOS 10 and earlier require the following line:
         player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
        
        guard let player = player else { return }
        
        player.play()
        
    } catch let error {
        print(error.localizedDescription)
    }
}

}

