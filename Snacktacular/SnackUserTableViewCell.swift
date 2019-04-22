//
//  SnackUserTableViewCell.swift
//  Snacktacular
//
//  Created by Kenyan Houck on 4/22/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
   let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class SnackUserTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userSinceLabel: UILabel!
    
    var snackUser: SnackUser{
        didSet{
            displayNameLabel.text = snackUser.displayName
            emailLabel.text = snackUser.email
            let formattedDate = dateFormatter.string(from: snackUser.userSince)
            userSinceLabel.text = "\(formattedDate)"
        }
    }
}
