
import UIKit
import AVFoundation

extension CameraController:AVCaptureMetadataOutputObjectsDelegate {
    func printFaceLayer(layer: CALayer, faceObjects: [AVMetadataFaceObject]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // hide all the face layers
        var faceLayers = [CALayer]()
        let orientation = UIDevice.current.orientation
        
        guard let layers = layer.sublayers else { return }
        
        for layer: CALayer in layers {
            
            if layer.name == "face" || layer.name == "container" || layer.name == "ref" {
                faceLayers.append(layer)
            }
        }
        for faceLayer in faceLayers {
            faceLayer.removeFromSuperlayer()
        }
        for faceObject in faceObjects {
            let featureLayer = CALayer()
            featureLayer.frame = faceObject.bounds
            featureLayer.borderColor = UIColor.red.cgColor
            featureLayer.borderWidth = 1.0
            featureLayer.name = "face"
            
            
            let position = faceObject.bounds
            let marginLeft:CGFloat = 10
            
            guard let image = userPhoto.image, let username = userData?.firstName, let ratingNumber = userData?.rating, let votes = userData?.votes else  { return }
            
            let container = CALayer()
            //container.backgroundColor = UIColor.red.cgColor
            container.frame = CGRect(x: position.origin.x + position.width + marginLeft, y: position.origin.y, width: 300, height: 100)
            container.name = "container"
            
            let photoProfile = CALayer()
            photoProfile.borderColor = UIColor.white.cgColor
            photoProfile.borderWidth = 1
            photoProfile.cornerRadius = 35 / 2
            photoProfile.frame = CGRect(x: 10, y: 10, width: 35, height: 35)
            photoProfile.contents = image.cgImage
            photoProfile.name = "profile"
            photoProfile.masksToBounds = true
            photoProfile.contentsScale = 2
             
            
            let textMargin = photoProfile.frame.origin.x + photoProfile.frame.width + 5
            
           
            let name = CATextLayer()
            name.string = username.capitalized
            name.fontSize = 35
            name.font = "AvenirNext-UltraLight" as CFTypeRef
            name.foregroundColor = UIColor.white.cgColor
            name.frame = CGRect(x: textMargin , y: photoProfile.frame.origin.y - 5, width: 150, height: 40)
            name.name = "name"
            name.contentsScale = 2
            name.shadowColor = UIColor(red:0.01, green:0.01, blue:0.01, alpha:0.40).cgColor
            name.shadowOffset = CGSize(width: 1, height: 1)
            name.shadowOpacity = 0.6
            name.shadowRadius = 0.5
            
           
            let rating = CATextLayer()
            rating.string = String(format: "%.2f", ratingNumber)
            rating.fontSize = 35 
            rating.font = "AvenirNext-Regular" as CFTypeRef
            rating.frame = CGRect(x: textMargin, y: name.frame.origin.y - 10 + name.frame.height + 5, width: 50, height: 40)
            rating.name = "rating"
            rating.contentsScale = 2
            rating.shadowColor = UIColor(red:0.01, green:0.01, blue:0.01, alpha:0.40).cgColor
            rating.shadowOffset = CGSize(width: 1, height: 1)
            rating.shadowOpacity = 0.6
            rating.shadowRadius = 0.5
            
            let ratingcCount = CATextLayer()
            ratingcCount.string = String(format: "%d", votes)
            ratingcCount.fontSize = 20
            ratingcCount.font = "AvenirNext-UltraLight" as CFTypeRef
            ratingcCount.foregroundColor = UIColor.white.cgColor
            ratingcCount.frame = CGRect(x: rating.frame.origin.x + rating.frame.width + 5, y: rating.frame.origin.y + rating.frame.height - 30, width: 150, height: 50)
            ratingcCount.name = "ratingcCount"
            ratingcCount.contentsScale = 2
            rating.shadowColor = UIColor(red:0.01, green:0.01, blue:0.01, alpha:0.40).cgColor
            rating.shadowOffset = CGSize(width: 1, height: 1)
            rating.shadowOpacity = 0.6
            rating.shadowRadius = 0.5
     
            
            //Circle
            let bounds = faceObject.bounds
            // Draw an ellipse
            let scale = CGFloat(2)
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: 40 , y: -40, width: bounds.width - 20 * scale, height: bounds.height + 20 * scale))
            
            
            let shape = CAShapeLayer()
            shape.path = ovalPath.cgPath
            shape.strokeColor = UIColor.white.cgColor
            shape.lineWidth = 2
            shape.frame = bounds
            shape.name = "face"
            shape.fillColor = UIColor.clear.cgColor
            //shape.strokeEnd = 0
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            shape.strokeEnd = 2
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 1
            shape.add(animation, forKey: nil)
            
            container.addSublayer(photoProfile)
            container.addSublayer(name)
            container.addSublayer(rating)
            container.addSublayer(ratingcCount)
            container.addSublayer(photoProfile)
            
           
           
            let rect = CALayer()
            rect.backgroundColor = UIColor.green.cgColor
            rect.name = "ref"
            rect.frame = CGRect(x: position.origin.x, y: position.origin.y, width: 2, height: 2)
            
            
            if orientation == .landscapeRight {
                let radians = CGFloat( -Double.pi / 2)
                let topMargin:CGFloat  = 30.0 //from the face
                let leftMargin: CGFloat = 30.0
                let translationAndRotation = CGAffineTransform(translationX: 0, y:0)
                    .rotated(by: -CGFloat.pi / 2)
                    .translatedBy(x: ((container.frame.width / 2) + leftMargin), y:  ((container.frame.height / 2) + topMargin))
                
                container.setAffineTransform(translationAndRotation)
 
                featureLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
 
                container.position = CGPoint(x: featureLayer.frame.origin.x, y: position.origin.y )
                
            }else if orientation == .landscapeLeft {
                let radians = CGFloat( Double.pi / 2)
                let leftMargin: CGFloat = 30.0
                let translationAndRotation = CGAffineTransform(translationX: 0, y:0)
                    .rotated(by: CGFloat.pi / 2)
                    .translatedBy(x: (container.frame.width/2) + position.width + leftMargin, y: -container.frame.height )
                
                container.setAffineTransform(translationAndRotation)
                
                featureLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
                
                container.position = CGPoint(x: featureLayer.frame.origin.x, y: position.origin.y )
            }
            
            layer.addSublayer(container)
            //layer.addSublayer(rect)
            //layer.addSublayer(featureLayer)
            
            self.overlayLayer = layer
        }
        CATransaction.commit()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var faceObjects = [AVMetadataFaceObject]()
        
        for metadataObject in metadataObjects {
            if let metaFaceObject = metadataObject as? AVMetadataFaceObject,
                metaFaceObject.type == AVMetadataObject.ObjectType.face {
                if let object = self.previewLayer?.transformedMetadataObject(
                    for: metaFaceObject) as? AVMetadataFaceObject {
                    faceObjects.append(object)
                }
            }
        }
        if faceObjects.count > 0, let layer = self.previewLayer{
            if !self.filterEnabled {
                faceObjects.removeAll()
            }
            self.printFaceLayer(layer: layer, faceObjects: faceObjects)
        }


    }
  
}
