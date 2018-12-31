//
//  Example.swift
//  Nosedive
//
//  Created by Victor Santos on 1/29/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import AVFoundation
final class INVExampleViewController: UIViewController {
    private var videoComponent: INVVideoComponent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoComponent = INVVideoComponent(
            atViewController: self,
            cameraType: .front,
            withAccess: .both
        )
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.videoComponent?.startLivePreview()
    }
}

