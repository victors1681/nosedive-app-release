//
//  CameraController.swift
//  Nosedive
//
//  Created by Victor Santos on 1/26/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import CoreImage

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate, PreviewPhotoContainerViewDelegate {
    
    enum CameraType {
        case front
        case back
    }
 
    var deviceOrientationOnCapture: UIDeviceOrientation!
     
     var overlayLayer: CALayer?
    
    var filterEnabled: Bool = true
    
    var userData: UserModel.User? {
        didSet {
            guard let user = userData else { return }
            let url = URL(string: user.photoUrl)
            userPhoto.kf.setImage(with: url)
        }
    }
    
    var userPhoto: UIImageView = UIImageView()
    
    fileprivate let sessionQueue = DispatchQueue(
        label: "camera",
        qos: .userInteractive,
        target: nil
    )
    
    var cameraCheck: CameraType = .back
    var previewLayer: AVCaptureVideoPreviewLayer?
    var input: AVCaptureDeviceInput?
    
    let dismissButton : UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "right-arrow-shadow"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    

    
    let capturePhotoButton: UIButton = {
        let btn  = UIButton()
        btn.setImage(#imageLiteral(resourceName: "capture-camera"), for: .normal)
        btn.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        btn.contentMode = .scaleToFill
        return btn
    }()
    
    let libraryButton: UIButton = {
        let btn  = UIButton()
        btn.setImage(#imageLiteral(resourceName: "photo-library"), for: .normal)
        btn.addTarget(self, action: #selector(gotoPhotoLibrary), for: .touchUpInside)
        btn.contentMode = .scaleToFill
        return btn
    }()
    
    let magicButton: UIButton = {
        let btn  = UIButton()
        btn.setImage(#imageLiteral(resourceName: "magic-wand"), for: .normal)
        btn.addTarget(self, action: #selector(handlerFilter), for: .touchUpInside)
        btn.contentMode = .scaleToFill
        return btn
    }()
    
    let rotateCameraButton: UIButton = {
        let btn  = UIButton()
        btn.setImage(#imageLiteral(resourceName: "rotate-camera"), for: .normal)
        btn.addTarget(self, action: #selector(handleFlipCamera), for: .touchUpInside)
        btn.contentMode = .scaleToFill
        return btn
    }()
    
    var flashMode: AVCaptureDevice.FlashMode = .auto
    
    let flashButton: UIButton = {
        let btn  = UIButton()
        btn.setImage(#imageLiteral(resourceName: "flash-auto"), for: .normal)
        btn.addTarget(self, action: #selector(handleFlashMode), for: .touchUpInside)
        btn.contentMode = .scaleToFill
        return btn
    }()
    
    
    let output = AVCapturePhotoOutput()
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupHUD()
        
        transitioningDelegate = self
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationItem.leftBarButtonItem = nil
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        UserModel().getUserById(uid: userId, completion: { (data) in
            self.userData = data
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        libraryButton.isEnabled = true
        captureSession.startRunning()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
    @objc func handlerFilter(){
        
        self.filterEnabled =  !self.filterEnabled
        
        if self.filterEnabled {
            magicButton.setImage(#imageLiteral(resourceName: "magic-wand"), for: .normal)
        }else{
            magicButton.setImage(#imageLiteral(resourceName: "magic-wand-disabled"), for: .normal)
        }
    }
    
    @objc func handleFlashMode(){
        
        switch self.flashMode {
        case .auto:
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: .normal)
            self.flashMode = .on
        case .on :
            flashButton.setImage(#imageLiteral(resourceName: "flash-off"), for: .normal)
            flashMode = .off
        case .off:
            flashButton.setImage(#imageLiteral(resourceName: "flash-auto"), for: .normal)
            flashMode = .auto
        }
    }
    
    @objc func handleFlipCamera(){
    
        captureSession.stopRunning()
        previewLayer?.removeFromSuperlayer()
        if self.cameraCheck == .back {
            self.setupCaptureSession(cemeraOrientation: .front)
            self.cameraCheck = .front
        }else{
             self.setupCaptureSession(cemeraOrientation: .back)
            self.cameraCheck = .back
        }
    }
    
  
    
    @objc func handleDismiss(){
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func gotoPhotoLibrary(){
        libraryButton.isEnabled = false
        captureSession.stopRunning()
        self.performSegue(withIdentifier: "libraryView", sender: nil)
        
    }
    

    
    fileprivate func setupHUD(){
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        
        
        view.addSubview(libraryButton)
        libraryButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 30, width: 50, height: 50)
        
        view.addSubview(rotateCameraButton)
        rotateCameraButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        
        view.addSubview(magicButton)
        magicButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 30, paddingBottom: 30, paddingRight: 0, width: 50, height: 50)
        
        view.addSubview(flashButton)
        flashButton.anchor(top: view.topAnchor, left: rotateCameraButton.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    }
    
    @objc func handleCapturePhoto(){
        
        let settings = AVCapturePhotoSettings()
        
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
     
        settings.flashMode = self.flashMode
        
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("Just about to take a photo.")
        self.deviceOrientationOnCapture = UIDevice.current.orientation // get device orientation on capture print("Device orientation:
        
    }
    
    
     func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
       
        guard let imageData = photo.fileDataRepresentation() else { return } 
        guard let originalImage = UIImage(data: imageData) else { return }
        
        var uiImage: UIImage = originalImage
        

        guard let cgImage = uiImage.cgImage else {  print("Error generating CGImage"); return }

        //FILTER
         // cgImage = simpleBlurFilterExample(inputImage: cgImage)
        
        uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: deviceOrientationOnCapture.getUIImageOrientationFromDevice(cameraType: self.cameraCheck))
  
        
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 5.0)
        uiImage.draw(in: (previewLayer?.frame)!)
        previewLayer!.render(in: UIGraphicsGetCurrentContext()!)
        
        uiImage =  UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        
        let containerView = PreviewPhotoContainerView()
        containerView.delegate = self
  
         
        let photoimageType = PhotoImageType(deviceOrientation: self.deviceOrientationOnCapture, cameraType: self.cameraCheck, image: uiImage)
        
 
        containerView.photoImageType = photoimageType
        
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor
            , right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
 
    
    func simpleBlurFilterExample(inputImage: CGImage) -> CGImage {
        
      
        // convert UIImage to CIImage
        let inputCIImage = CIImage(cgImage: inputImage)
        let filter = CIFilter(name: "CIPhotoEffectChrome", withInputParameters:
            [kCIInputImageKey: inputCIImage])!

         let outputImage = filter.outputImage!
        outputImage.applyingFilter("CIColorControls", parameters: ["inputBrightness" : 5])
        
     
        let context = CIContext()
        let cgImage = context.createCGImage(outputImage, from: (outputImage.extent))
        return cgImage!
    }
    
    
    
    fileprivate func setupCaptureSession(cemeraOrientation: CameraType = .back){
        
        //1.setup inputs
      
        //guard let capture = AVCaptureDevice.default(for: .video) else { return }
        
        var capture: AVCaptureDevice?
        
        if cemeraOrientation == .back{
              capture = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    
        }else{
              capture = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
        }
        
        guard let captureDevise = capture else { return }
        
        do {
            
            if input != nil {
                captureSession.removeInput(input!)
            }
            
             input = try AVCaptureDeviceInput(device: captureDevise)
            
            guard let inputDevise = input else { return }
        
            if captureSession.canAddInput(inputDevise){
              captureSession.addInput(inputDevise)
            }
        }catch let err {
            print("Could not setup camera input", err)
            
           // let alert = UIAlertController(title:err.localizedDescription, message:err.localizedFailureReason, preferredStyle:.Alert)
            
//            let alert = UIAlertController(title: err.localizedDescription, message: err.localizedDescription, preferredStyle: .alert)
//
//            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
//
//
//
//            }
//            alert.addAction(settingsAction)
//            self.present(alert,animated:true,completion:nil)
            
            let dialog = DialogViewController()
            dialog.textView.text = "I can not access to your camera.\n Please go to:\n Settings -> Nosedice -> Camera \n And turn it on."
            dialog.image = #imageLiteral(resourceName: "settings-icon")
            dialog.background = true
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            self.present(dialog, animated: true, completion: nil)
            
        }
        
        //2.setup output
        
        
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }
        
        //3.setup output preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.frame
        view.layer.insertSublayer(previewLayer!, at: 0)
        
        captureSession.startRunning()
        
   
            let metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: self.sessionQueue)
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
            }
            
            if metadataOutput.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
                let metaType = type.rawValue
                
                return metaType == AVMetadataObject.ObjectType.face.rawValue
                
            }) {
                metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
            } else {
//                self.errorBlock?(INVVideoControllerErrors.undefinedError)
            }
        
    }
    
    func askForCameraPermission(completionHandler: @escaping (_ granted: Bool)->Void) {
        let mediaType = AVMediaType.video
        AVCaptureDevice.requestAccess(for: mediaType) {
            (granted) in
            if granted == true {
                print("Granted access to \(mediaType)" )
            } else {
                print("Not granted access to \(mediaType)")
            }
            completionHandler(granted)
        }
    }
    
    
    func goToShare(image: PhotoImageType) {
        
        self.performSegue(withIdentifier: "shareView", sender: image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "shareView" {
            let sharePhoto = segue.destination as! SharePhotoViewController
            
            guard let image = sender as? PhotoImageType else { return }
            
            sharePhoto.selectedImage = image
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
