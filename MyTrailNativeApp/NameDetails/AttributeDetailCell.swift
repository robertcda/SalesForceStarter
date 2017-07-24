//
//  AttributeDetailCell.swift
//  MyTrailNativeApp
//
//  Created by Robert on 21/07/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

class AttributeDetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
