//
//  ModelInterface.swift
//  MyTrailNativeApp
//
//  Created by Robert on 20/07/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SmartStore

typealias SimpleBlock = ()->Void

class ModelInterface{
    static var instance = ModelInterface()
    
    var store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    var globalStore: SFSmartStore = SFSmartStore.sharedGlobalStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    
    private init() {
        //self.store.removeAllSoups()
    }
    
    //MARK: Accounts Interface
    typealias AccountsHandler = ([Account]?)->Void
    
    func accounts(accountsHandler:@escaping AccountsHandler){
        // First check if the soup is available locally
        
        if Account.isSoupLoaded(store: self.store){
            
            // If it is loaded then get the Accounts from the local store.
            accountsHandler(Account.getAccountsFromStore(store: self.store))
            
        }else{
            // If soup is not loaded then we get the Accounts from the network.
            self.reloadAccountsFromNetwork {
                accountsHandler(Account.getAccountsFromStore(store: self.store))
            }
        }
    }
    
    func reloadAccountsFromNetwork(completion:@escaping SimpleBlock){
        Account.executeGetAccounts(store: self.store, completion: completion)
    }
}


