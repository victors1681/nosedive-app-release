//
//  UploadFileModel.swift
//  Nosedive
//
//  Created by Victor Santos on 1/14/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class UploadFileModel{

    var storageRef: StorageReference!
    var profilePath: String
    var postPath: String
    
    enum FileType{
        case profile
        case post
    }
    
    init(){
         storageRef = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser?.uid
        self.profilePath = "\(currentUser!)/profile/"
        self.postPath = "\(currentUser!)/post/"
    }
    
    func uploadFile(image: UIImage, fileType: FileType, completion: @escaping (_ sucess: Bool,_ imageUrl: String,_ fileName: String)->()){
        
        if fileType == .profile {
            self.uploadImageProfile(image: image, completion: { (success, path, filename) in
                completion(success, path, filename)
            })
        }else {
            self.uploadPhotoPost(image: image, completion: { (success, path, filename) in
                completion(success, path, filename)
            })
        }

    }
    
    private func uploadPhotoPost(image: UIImage, completion: @escaping(_ sucess: Bool,_ imageUrl: String,_ fileName: String)->()) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.7) else { return }
        let imageName = "\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let path = "\(self.postPath)/\(imageName)"
        
        self.uploadImageFile(path: path, imageData: imageData, imageName: imageName) { (success, path, filename) in
            
            completion(success, path, filename)
        }
        
    }
    
    
    private func uploadImageProfile(image: UIImage, completion: @escaping (_ sucess: Bool,_ imageUrl: String,_ fileName: String)->()) {
        
        let randomName = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let thumbnailName = "\(randomName)_thumbnail.jpg"
        let imageNormalName = "\(randomName).jpg"
        
        let size = CGSize(width: 300, height: 300)
        let thumbnailImage = image.resizeImage(targetSize: size)
        
        
        guard let regularImageData = UIImageJPEGRepresentation(image, 0.7) else {return}
        guard let thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 1) else {return}
        
        
        //Upload regular
        let thumbnailPath = "\(self.profilePath)/\(thumbnailName)"
        let regularPath = "\(self.profilePath)/\(imageNormalName)"
        let userModel = UserModel()
        
        self.uploadImageFile(path: regularPath, imageData: regularImageData, imageName: imageNormalName) { (sucess, imageUrl, imageName) in
            
            if !sucess { return }
            
            //upload Thumbnail
            self.uploadImageFile(path: thumbnailPath, imageData: thumbnailData, imageName: thumbnailName) { (sucessThmb, imageUrlThumb, imageNameThumb) in
                
                userModel.updateUserImageUserInfo(url: imageUrl, imageName: imageName, urlThumbnail: imageUrlThumb, imageNameThumbnail: imageNameThumb)
                
                UserDefaults.standard.set(thumbnailPath, forKey: "storagePath")
                UserDefaults.standard.synchronize()
                completion(sucessThmb, imageUrlThumb, imageNameThumb)
                
            }
            
        }
        
    }
    
    private func uploadImageFile(path: String, imageData data: Data, imageName: String,  completion: @escaping (_ sucess: Bool,_ imageUrl: String,_ fileName: String)->()){
        
        // [START uploadimage]
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        self.storageRef.child(path).putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                completion(false, error.localizedDescription, "")
                return
            }
           
            //Return path
            if let link = metadata?.downloadURL()?.absoluteString {
                completion(true, link, imageName)
            }
        }
    
    }
    
}
