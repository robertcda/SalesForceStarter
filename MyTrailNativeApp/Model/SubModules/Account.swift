
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
        case Id, name, accountNumber, dirty, local
        static let all = [Attributes.Id,Attributes.name,Attributes.dirty,Attributes.local]
        
        var path: String{
            switch self {
            case .Id:               return "Id"
            case .name:             return "Name"
            case .accountNumber:    return "AccountNumber"
                
                // Custom locally created coloumns
            case .dirty:            return "dirty"
                
                // required for Sync
            case .local: return "__local__"
            }
        }
        
        var type: String{
            switch self {
            case .name,.accountNumber,.Id,.local:
                return kSoupIndexTypeString
                /*
                return kSoupIndexTypeInteger
                return kSoupIndexTypeInteger
                return kSoupIndexTypeFloating
                return kSoupIndexTypeFullText
                return kSoupIndexTypeJSON1
                 */
            case .dirty:
                return kSoupIndexTypeInteger
            }
        }
    }

    //MARK: Query
    static let getQuery: String = "SELECT Id,Name,AccountNumber FROM Account"

    //MARK: - Attributes declarations.
    private var _Id: String?
    private var _name: String?
    private var _accountNumber: String?
    
    // Local variable
    private var _dirty:Bool = false
    
    // Required for Sync
    private var _local:String?
    
    
    static let dirtyChangedNotification = Notification(name: NSNotification.Name("AccountDirtyValueChanges"),
                                                         object: nil)
    var dirty:Bool{
        get{
            return _dirty
        }
        set{
            self._dirty = newValue
            NotificationCenter.default.post(Account.dirtyChangedNotification)
            self.storeValuesToStore(store: ModelInterface.instance.store)
            
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
            
            
            if let idIndex = SFSoupIndex(path: Account.Attributes.Id.path,
                                           indexType: Account.Attributes.Id.type,
                                           columnName: Account.Attributes.Id.path){
                indexSpecs.append(idIndex)
            }
            
            
            if let dirtyBit = SFSoupIndex(path: Account.Attributes.dirty.path,
                                         indexType: Account.Attributes.dirty.type,
                                         columnName: Account.Attributes.dirty.path){
                indexSpecs.append(dirtyBit)
            }
            
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
    //MARK: storeValuesToStore
    func storeValuesToStore(store:SFSmartStore){
        do{
            try store.upsertEntries([self.accountFields],
                                    toSoup: Account.soupName,
                                    withExternalIdPath: Account.Attributes.Id.path)
        }catch let error{
            print("\(#function):\(error)")
        }
    }
    
    
    //MARK:-
    //MARK: JSON -> Account
    
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
        
        guard let idVal = accountInfoDict[Account.Attributes.Id.path] as? String else{
            return nil
        }
        _Id = idVal

        
        guard let name = accountInfoDict[Account.Attributes.name.path] as? String else{
            return nil
        }
        _name = name
        
        guard let accountNumber = accountInfoDict[Account.Attributes.accountNumber.path] as? String else{
            return nil
        }
        _accountNumber = accountNumber
        
        if let dirtyNumber = accountInfoDict[Account.Attributes.dirty.path] as? NSNumber{
            _dirty = dirtyNumber.boolValue
        }
    }
    
    //MARK: Account -> JSON
    private var accountFields: [String:Any]{
        var accountFields = [String:Any]()
        accountFields[Account.Attributes.Id.path] = _Id
        accountFields[Account.Attributes.accountNumber.path] = _accountNumber
        accountFields[Account.Attributes.name.path] = _name
        accountFields[Account.Attributes.dirty.path] = NSNumber(value:self.dirty)
        return accountFields
    }
    
    //MARK:-
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
                            do {
                                let arrayOfUpsertedEntries = try store.upsertEntries(records,
                                                        toSoup: Account.soupName,
                                                        withExternalIdPath: Account.Attributes.accountNumber.path)
                                print("arrayOfUpsertedEntries:\(arrayOfUpsertedEntries)")
                            }catch let error{
                                print("\(#function): error:\(error):")
                            }
                        }
                        completion()
                        
        })
    }
    
    //MARK: NETWORK PATCH/UPDATE
    func update(completion: @escaping SimpleBlock,
                errorCompletion: SimpleBlock? = nil){
        let restAPI = SFRestAPI.sharedInstance()
        
        let updateRquest = restAPI.requestForUpdate(withObjectType: "Account",
                                                    objectId: Account.Attributes.Id.path,
                                                    fields: self.accountFields)
        
        restAPI.send(updateRquest,
                     fail: { error in
                        print("\(#function): fail, error:\(error)")
                        print("Account:\(#function): ErrorBlock")
                        errorCompletion?()
        },
                     complete: { response in
                        print("Account:\(#function): CompletionBlock")
                        completion()
                        
        })

        
    }

    
    //MARK: NETWORK POST
    func post(){
        
    }
    
    //MARK:-
    
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
