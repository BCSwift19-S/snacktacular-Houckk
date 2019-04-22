//
//  Review.swift
//  Snacktacular
//
//  Created by Kenyan Houck on 4/14/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": timeIntervalDate]
    }
    
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String)
    {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
        
    }
    
    
    
    convenience init(dictionary: [String : Any]){
        
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String
        //print("😔 Calling Convenience init")
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
    }
    
    
    
    
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    
    
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
       
        //create dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, well have a document ID
        if self.documentID != ""
        {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("**** ERROR: Updating document \(self.documentID) in spot \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("$$$$$ - Document updated with ref ID \(ref.documentID)")
                    spot.updateAverageRating {
                        completion(true)
                    }
                }
                
            }
        } else {
            var ref: DocumentReference? = nil //Let firestore create the new document ID
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave){ error in
                if let error = error {
                    print("**** ERROR: creating new document \(self.documentID) \(error.localizedDescription) ASDFASDFASDFASDF")
                    completion(false)
                } else {
                    print("$$$$$ - new document created with ref ID \(ref?.documentID ?? "Unknown")")
                    spot.updateAverageRating {
                        completion(true)
                    }
                }
            }
        }
    }
    func deleteData(spot: Spot, completed: @escaping (Bool) -> ())
    {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete () { error in
            if let error = error {
                print("😡😡😡😡 ERROR: Deleting review documentID \(self.documentID) \(error.localizedDescription)")
                completed(false)
            } else {
                spot.updateAverageRating {
                    completed(true)
                }
            }
        }
        
    }
}
