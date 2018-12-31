//
//  SharePhotoViewExtension.swift
//  Nosedive
//
//  Created by Victor Santos on 2/4/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import FacebookShare

extension SharePhotoViewController {
    
    func showShareDialog<C: ContentProtocol>(_ content: C, mode: ShareDialogMode = .automatic) {
        let dialog = ShareDialog(content: content)
        dialog.presentingViewController = self
        dialog.mode = mode
        do {
            try dialog.show()
        } catch (let error) {
            let alertController = UIAlertController(title: "Invalid share content", message: "Failed to present share dialog with error \(error)")
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func sharePhotoOnFacebook(caption: String, image: UIImage) {
        var photo = Photo(image: image, userGenerated: true)
        photo.caption = caption
        let content = PhotoShareContent(photos: [photo])
         showShareDialog(content)
    }
}

