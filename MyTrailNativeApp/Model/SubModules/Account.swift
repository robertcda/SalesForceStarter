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

class Account {
    static let soupName = "AccountSoup"
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
                /*
                return kSoupIndexTypeInteger
                return kSoupIndexTypeInteger
                return kSoupIndexTypeFloating
                return kSoupIndexTypeFullText
                return kSoupIndexTypeJSON1
                 */
            }
        }
    }

    //MARK: Query
    static let getQuery: String = "SELECT Name,AccountNumber FROM Account"

    //MARK: - Attributes declarations.
    private var _name: String?
    private var _accountNumber: String?
    
    
    static let dirtyChangedNotification = Notification(name: NSNotification.Name("AccountDirtyValueChanges"),
                                                         object: nil)
    
    var dirty:Bool = false{
        didSet{
            NotificationCenter.default.post(Account.dirtyChangedNotification)
        }
    }
    
    //MARK: Accessors & Settors
    var name:String?{
        get{
            return _name
        }
        set{
            if _name != newValue{
                self.dirty = true
                self._name = newValue
            }
        }
    }
    
    var accountNumber:String?{
        get{
            return _accountNumber
        }
        set{
            if _name != newValue{
                self.dirty = true
                self._accountNumber = newValue
            }
        }
    }

    
    //MARK: Soup Registering
    
    class func isSoupLoaded(store:SFSmartStore) -> Bool{
        if store.soupExists(Account.soupName){
            return true
        }else{
            return false
        }
    }

    class func registerSoupInTheStore(store:SFSmartStore){
        print("Account:\(#function)")
        if self.isSoupLoaded(store: store) == false{
            
            var indexSpecs:[SFSoupIndex] = []
            
            if let nameIndex = SFSoupIndex(path: Account.Attributes.name.path,
                                        indexType: Account.Attributes.name.type,
                                        columnName: Account.Attributes.name.path){
                indexSpecs.append(nameIndex)
            }
            
            
            indexSpecs.append(SFSoupIndex(path: Account.Attributes.accountNumber.path,
                                          indexType: Account.Attributes.accountNumber.type,
                                          columnName: Account.Attributes.accountNumber.path))

            
            do{
                try store.registerSoup(Account.soupName,
                                       withIndexSpecs: indexSpecs,
                                       error: ())
            }catch let error{
                print("Account: Error caught:\(error)")
            }
        }
    }
    
    //MARK: JSON to Account
    
    class func createAccountsWithJSON(accountsJSONArray:[[String:Any]]) -> [Account]{
        print("Account:\(#function)")
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
        _name = name
        
        guard let accountNumber = accountInfoDict[Account.Attributes.accountNumber.path] as? String else{
            return nil
        }
        _accountNumber = accountNumber

    }
    
    //MARK: NETWORK Get accounts
    class func executeGetAccounts(store: SFSmartStore,
                            completion: @escaping SimpleBlock,
                            errorCompletion: SimpleBlock? = nil){
        print("Account:\(#function)")
        Account.registerSoupInTheStore(store: store)
        
        let restAPI = SFRestAPI.sharedInstance()
        let request = restAPI.request(forQuery: Account.getQuery)
        
        restAPI.send(request,
                     fail: { error in
                        print("\(#function): fail, error:\(error)")
                        print("Account:\(#function): ErrorBlock")
                        errorCompletion?()
        },
                     complete: { response in
                        print("Account:\(#function): CompletionBlock")
                        if let responseDict = response as? [String:Any],
                            let records = responseDict["records"] as? [[String:Any]]{
                            for record in records{
                                do {
                                    try store.upsertEntries([record],
                                                                 toSoup: Account.soupName,
                                                                 withExternalIdPath: Account.Attributes.accountNumber.path)
                                }catch let error{
                                    print("\(#function): error:\(error):")
                                }
                                
                            }
                        }
                        completion()
                        
        })
    }
    //MARK: NETWORK POST
    func post(){
        
    }
    
    //MARK: LOCAL Get accounts
    class func getAccountsFromStore(store:SFSmartStore)->[Account]?{
        print("Account:\(#function)")
        let query = SFQuerySpec.newAllQuerySpec(Account.soupName,
                                                withOrderPath: Account.Attributes.name.path,
                                                with: SFSoupQuerySortOrder.ascending,
                                                withPageSize: 100)
        do {
            let accuntsJsonArray = try store.query(with: query, pageIndex: 0)
            let accounts = Account.createAccountsWithJSON(accountsJSONArray: accuntsJsonArray as! [[String:Any]])
            return accounts
        }catch let e{
            print("\(#function): Error:\(e)")
            return nil
        }
    }
    // Mark:
}
