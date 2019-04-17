//
//  Photo.swift
//  Snacktacular
//
//  Created by Kenyan Houck on 4/15/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String //Universal Unique Identifier
    var dictionary: [String: Any]{
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String)
    {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
    
    
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //convert photo to a Data type so it can be saved on Firestore
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("^^^^^^ ERROR: Could not convert image to data format")
            return completion(false)
        }
        documentUUID = UUID().uuidString //generate a unique ID to use for the Photo images
        
        //create a ref to upload storage to spot.documentID's folder (bucket), with the name we created
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        storageRef.putData(photoData)
        let uploadTask = storageRef.putData(photoData)
        
        uploadTask.observe(.success) { (snapshot) in
            
            //create dictionary representing the data we want to save
            let dataToSave = self.dictionary
            // This will either create a new doc or update the existing doc
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("**** ERROR: Updating document \(self.documentUUID) in spot \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("$$$$$ - Document updated with ref ID \(ref.documentID)")
                    completion(true)
                }
                
            }
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("*****ERROR: Upload task for file \(self.documentUUID) failed in spot \(spot.documentID)")
            }
            return completion(false)
        }
    }
}
