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


class Account {
    
    //MARK: - Attribute constants.
    enum Attributes{
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

    //MARK: - Attributes declarations.
    var name: String?
    var accountNumber: String?
    
    static let getQuery: String = "SELECT Name,AccountNumber FROM Account"
    
    //MARK: Soup Registering
    class func registerSoupInTheStore(){
        let store = ModelInterface.instance.store
        if store.soupExists(kAccountSoupName) == false{
            
            var indexSpecs:[SFSoupIndex] = []
            
            indexSpecs.append(SFSoupIndex(path: Account.Attributes.name.path,
                                          indexType: Account.Attributes.name.type,
                                          columnName: Account.Attributes.name.path))
            
            indexSpecs.append(SFSoupIndex(path: Account.Attributes.accountNumber.path,
                                          indexType: Account.Attributes.accountNumber.type,
                                          columnName: Account.Attributes.accountNumber.path))

            
            do{
                try store.registerSoup(kAccountSoupName,
                                       withIndexSpecs: indexSpecs,
                                       error: ())
            }catch let error{
                print("Account: Error caught:\(error)")
            }
        }
    }
    
    //MARK: JSON to Account
    
    class func createAccounts(accountsJSONArray:[[String:Any]]) -> [Account]{
        var accounts = [Account]()
        for accountDict in accountsJSONArray{
            if let account = Account(accountInfoDict: accountDict){
                accounts.append(account)
            }
        }
        return accounts
    }
    
    init?(accountInfoDict:[String:Any]) {
        guard let name = accountInfoDict[Account.Attributes.name.path] as? String else{
            return nil
        }
        self.name = name
        
        guard let accountNumber = accountInfoDict[Account.Attributes.accountNumber.path] as? String else{
            return nil
        }
        self.accountNumber = accountNumber

    }
    
}
