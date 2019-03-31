//
//  Spot.swift
//  Snacktacular
//
//  Created by Kenyan Houck on 3/30/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Spot{
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees{
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees{
        return coordinate.latitude
    }
    
    
    var dictionary: [String: Any]{
        return ["name": name, "address": address, "longitude": longitude, "latitude": latitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String)
    {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init(){
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    
    func saveData(completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        //Grab User ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("**** Could not save data bc we dont have a valid user posting ID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        //create dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, well have a document ID
        if self.documentID != ""
        {
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                print("**** ERROR: Updating document \(self.documentID) \(error.localizedDescription)")
                    completion(false)
            } else {
                    print("$$$$$ - Document updated with ref ID \(ref.documentID)")
                    completion(true)
                }
                
            }
        } else {
            var ref: DocumentReference? = nil //Let firestore create the new document ID
            ref = db.collection("spots").addDocument(data: dataToSave){ error in
                if let error = error {
                    print("**** ERROR: creating new document \(self.documentID) \(error.localizedDescription) ASDFASDFASDFASDF")
                    completion(false)
                } else {
                    print("$$$$$ - new document created with ref ID \(ref?.documentID ?? "Unknown")")
                    completion(true)
                }
            }
        }
    }
}
