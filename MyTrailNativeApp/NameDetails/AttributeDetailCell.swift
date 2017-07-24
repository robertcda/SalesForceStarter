//
//  AttributeDetailCell.swift
//  MyTrailNativeApp
//
//  Created by Robert on 21/07/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

protocol AttributeData {
    var title:String {get}
    var value:String {get set}
}

class AttributeDetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var textField: UITextField?
    
    var attributeData:AttributeData? = nil{
        didSet{
            self.titleLabel?.text = self.attributeData?.title
            self.textField?.text = self.attributeData?.value
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textField?.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension AttributeDetailCell: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("\(#function)")
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("\(#function)")
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let textVal = textField.text{
            self.attributeData?.value = textVal
        }

        return true
    }
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("\(#function)")
        if let textVal = textField.text{
            self.attributeData?.value = textVal
        }
    }
}
