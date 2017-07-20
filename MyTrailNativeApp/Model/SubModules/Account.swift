//
//  Account.swift
//  MyTrailNativeApp
//
//  Created by Robert on 20/07/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SmartStore

let kAccountSoupName = "AccountSoup"

enum AccountConstants{
    case name, accountNumber
    
    var path: String{
        switch self {
        case .name:
            return "Name"
        case .accountNumber:
            return "AccountNumber"
        }
    }
    
    var type: String{
        switch self {
        case .name,.accountNumber:
            return kSoupIndexTypeString
        }
    }
}

class Account {
    var name: String?
    var accountNumber: String?
    
    static let getQuery: String = "SELECT Name,AccountNumber FROM Account"
    
    class func registerSoupInTheStore(){
        let store = ModelInterface.instance.store
        if store.soupExists(kAccountSoupName) == false{
            
            var indexSpecs:[SFSoupIndex] = []
            
            indexSpecs.append(SFSoupIndex(path: AccountConstants.name.path,
                                          indexType: AccountConstants.name.type,
                                          columnName: AccountConstants.name.path))
            
            indexSpecs.append(SFSoupIndex(path: AccountConstants.accountNumber.path,
                                          indexType: AccountConstants.accountNumber.type,
                                          columnName: AccountConstants.accountNumber.path))

            
            do{
                try store.registerSoup(kAccountSoupName,
                                       withIndexSpecs: indexSpecs,
                                       error: ())
            }catch let error{
                print("Account: Error caught:\(error)")
            }
        }
    }
}
