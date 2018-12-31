//
//  INVVideoViewController.swift
//
//
//  Created by Krzysztof Kryniecki on 9/23/16.
//  Copyright © 2016 InventiApps. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreImage
import ImageIO
import CoreFoundation

enum INVVideoControllerErrors: Error {
    case unsupportedDevice
    case videoNotConfigured
    case undefinedError
}
enum INVVideoAccessType {
    case both
    case video
    case audio
    case unknown
}

class INVVideoViewController: UIViewController {
    var errorBlock: ((_ error: Error) -> Void)?
    var componentReadyBlock: (() -> Void)?
    private enum INVVideoQueuesType: String {
        case session
        case camera
    }
    private var currentAccessType: INVVideoAccessType = .unknown
    var audioOutput: AVCaptureAudioDataOutput?
    var captureOutput: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate let sessionQueue = DispatchQueue(
        label: INVVideoQueuesType.session.rawValue,
        qos: .userInteractive,
        target: nil
    )
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var runtimeCaptureErrorObserver: NSObjectProtocol?
    fileprivate var movieFileOutputCapture: AVCaptureMovieFileOutput?
    fileprivate let kINVRecordedFileName = "movie.mov"
    private var isAssetWriter: Bool = false

    private func deviceWithMediaType(
        mediaType: AVMediaType,
        position: AVCaptureDevice.Position?) throws -> AVCaptureDevice? {

        if mediaType == .audio {
            return AVCaptureDevice.default(for: .audio)
        }
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: mediaType, position: position!)
        
        
        // let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: mediaType, position: position!).devices.first
        
       // return devices
//        if let devices = AVCaptureDevice.devices(withMediaType: mediaType),
//            let devicePosition = position {
//            for deviceObj in devices {
//                if let device = deviceObj as? AVCaptureDevice,
//                    device.position == devicePosition {
//                    return device
//                }
//            }
//        } else {
//            if let devices = AVCaptureDevice.devices(withMediaType: mediaType),
//                let device = devices.first as? AVCaptureDevice {
//                return device
//            }
//        }
//        throw INVVideoControllerErrors.unsupportedDevice
    }

    private func setupPreviewView(session: AVCaptureSession) throws {
       // if
            let previewLayer = AVCaptureVideoPreviewLayer(session: session) //{
         
            
            previewLayer.masksToBounds = true
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
            self.previewLayer?.frame = self.view.frame
//        } else {
//            throw INVVideoControllerErrors.undefinedError
//        }
    }

    private func setupCaptureSession(cameraType: AVCaptureDevice.Position) throws {
        guard let videoDevice = try self.deviceWithMediaType(
            mediaType: AVMediaType.video,
            position: cameraType
            ) else { return }
        
        let captureDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        if self.captureSession.canAddInput(captureDeviceInput) {
            self.captureSession.addInput(captureDeviceInput)
        } else {
            errorBlock?(INVVideoControllerErrors.unsupportedDevice)
        }
        
        guard let audioDevice = try self.deviceWithMediaType(
            mediaType: AVMediaType.audio,
            position: nil
            )else { return }
        
        let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
        if self.captureSession.canAddInput(audioDeviceInput) {
            self.captureSession.addInput(audioDeviceInput)
        } else {
            errorBlock?(INVVideoControllerErrors.unsupportedDevice)
        }
    }

    private func handleVideoRotation() {
        if let connection =  self.previewLayer?.connection {
            let orientation: UIDeviceOrientation = .portrait
            let previewLayerConnection: AVCaptureConnection = connection
            if previewLayerConnection.isVideoOrientationSupported,
                let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
                previewLayer?.connection?.videoOrientation = videoOrientation
            }
            if let outputLayerConnection: AVCaptureConnection = self.captureOutput?.connection(
                with: AVMediaType.video) {
                if outputLayerConnection.isVideoOrientationSupported,
                    let videoOrientation = AVCaptureVideoOrientation(rawValue:
                        orientation.rawValue) {
                    outputLayerConnection.videoOrientation = videoOrientation
                    outputLayerConnection.isVideoMirrored = true
                }
            }
        }
    }

    private func requestVideoAccess(requestedAccess: INVVideoAccessType) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (isGranted) in
            if isGranted {
                switch self.currentAccessType {
                case .unknown:
                    self.currentAccessType = .video
                case .audio:
                    self.currentAccessType = .both
                default:
                    break
                }
            }
            if self.currentAccessType == requestedAccess {
                DispatchQueue.main.async {
                    self.componentReadyBlock?()
                }
            }
        })
    }

    private func requestAudioAccess(requestedAccess: INVVideoAccessType) {
        AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (isGranted) in
            if isGranted {
                switch self.currentAccessType {
                case .unknown:
                    self.currentAccessType = .audio
                case .video:
                    self.currentAccessType = .both
                default:
                    break
                }
            }
            if self.currentAccessType == requestedAccess {
                DispatchQueue.main.async {
                    self.componentReadyBlock?()
                }
            }
        })
    }

    func setupDeviceCapture(requiredAccessType: INVVideoAccessType) {
        if self.currentAccessType != requiredAccessType {
            switch requiredAccessType {
            case .both:
                self.requestVideoAccess(requestedAccess: requiredAccessType)
                self.requestAudioAccess(requestedAccess: requiredAccessType)
                break
            case .video:
                self.requestVideoAccess(requestedAccess: requiredAccessType)
                break
            case .audio:
                self.requestAudioAccess(requestedAccess: requiredAccessType)
                break
            case .unknown:
                self.errorBlock?(INVVideoControllerErrors.videoNotConfigured)
                break
            }
        } else {
            DispatchQueue.main.async {
                self.componentReadyBlock?()
            }
        }
    }
    // Sets Up Capturing Devices
    func configureDeviceCapture(cameraType: AVCaptureDevice.Position) {
        do {
            try self.setupPreviewView(session: self.captureSession)
        } catch {
            errorBlock?(INVVideoControllerErrors.undefinedError)
        }
        do {
            try self.setupCaptureSession(cameraType: cameraType)
        } catch INVVideoControllerErrors.unsupportedDevice {
            errorBlock?(INVVideoControllerErrors.unsupportedDevice)
        } catch {
            errorBlock?(INVVideoControllerErrors.undefinedError)
        }
    }

}

extension INVVideoViewController {
    func startCaptureSesion() {
        self.captureSession.startRunning()
        self.previewLayer?.connection?.automaticallyAdjustsVideoMirroring = false
        self.previewLayer?.connection?.isVideoMirrored = true
        self.runtimeCaptureErrorObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVCaptureSessionRuntimeError,
            object: self.captureSession,
            queue: nil
        ) { [weak self] _ in
            self?.errorBlock?(INVVideoControllerErrors.undefinedError)
        }
    }

    func stopCaptureSession() {
        self.captureSession.stopRunning()
        if let observer = self.runtimeCaptureErrorObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

//    func startMetaSession() {
//        let metadataOutput = AVCaptureMetadataOutput()
//        metadataOutput.setMetadataObjectsDelegate(self, queue: self.sessionQueue)
//        if self.captureSession.canAddOutput(metadataOutput) {
//            self.captureSession.addOutput(metadataOutput)
//        }
//        
//        if metadataOutput.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
//             let metaType = type.rawValue
//         
//                return metaType == AVMetadataObject.ObjectType.face.rawValue
//            
//        }) {
//            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
//        } else {
//            self.errorBlock?(INVVideoControllerErrors.undefinedError)
//        }
//    }
}
