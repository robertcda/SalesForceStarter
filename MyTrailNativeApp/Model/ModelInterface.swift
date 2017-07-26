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
import SmartSync

typealias SimpleBlock = ()->Void

class ModelInterface{
    static var instance = ModelInterface()
    
    var store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    var globalStore: SFSmartStore = SFSmartStore.sharedGlobalStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    
    var syncManager:SFSmartSyncSyncManager {
      return SFSmartSyncSyncManager.sharedInstance(for: store)
    }
    
    private init() {
        //self.store.removeAllSoups()
    }
    
    //MARK: Accounts Interface
    typealias AccountsHandler = ([Account]?)->Void
    
    func accounts(accountsHandler:@escaping AccountsHandler){
        print("ModelInterface:\(#function)")
        // First check if the soup is available locally
        
        if Account.isSoupLoaded(store: self.store){
            
            // If it is loaded then get the Accounts from the local store.
            accountsHandler(Account.getAccountsFromStore(store: self.store))
            
        }else{
            // If soup is not loaded then we get the Accounts from the network.
            self.refreshRemoteData {
                accountsHandler(Account.getAccountsFromStore(store: self.store))
            }
        }
    }
    
    
    func reloadAccountsFromNetwork(completion:@escaping SimpleBlock){
        print("ModelInterface:\(#function)")
        completion()
        Account.executeGetAccounts(store: self.store, completion: completion)
    }
    
    //MARK:- Sync implementation
    
    var syncID: Int = 0
    
    func refreshRemoteData(completion:@escaping SimpleBlock){
        if Account.isSoupLoaded(store: self.store) == false{
            Account.registerSoupInTheStore(store: self.store)
        }
        
        let syncCompletionHandler:SFSyncSyncManagerUpdateBlock = { syncState in
            print("SFSyncManagerUpdateBlock: refreshRemoteData syncState:\(syncState)")
            guard let syncState = syncState else{
                return
            }
            if syncState.isDone() || syncState.hasFailed(){
                self.syncID = syncState.syncId
                completion()
            }
        }
        
        let syncDownTarget = SFSoqlSyncDownTarget.newSyncTarget(Account.getQuery)
        let syncOptions = SFSyncOptions.newSyncOptions(forSyncDown: .leaveIfChanged)
        
        if syncID == 0{
            self.syncManager.syncDown(with: syncDownTarget,
                                      options: syncOptions,
                                      soupName: Account.soupName,
                                      update: syncCompletionHandler)
        }else{
            self.syncManager.reSync(NSNumber(integerLiteral: syncID), update: syncCompletionHandler)
        }
        
    }
    
    
    func updateRemoteData(completion:@escaping SimpleBlock){
        
        let syncCompletionHandler:SFSyncSyncManagerUpdateBlock = { syncState in
            print("SFSyncManagerUpdateBlock: updateRemoteData syncState:\(syncState)")
            guard let syncState = syncState else{
                return
            }
            if syncState.isDone() || syncState.hasFailed(){
                completion()
            }
        }
        
        let syncOptions = SFSyncOptions.newSyncOptions(forSyncUp: Account.Attributes.all.map{$0.path},
                                                       mergeMode: .overwrite)
        self.syncManager.syncUp(with: syncOptions,
                                soupName: Account.soupName,
                                update: syncCompletionHandler)
        
    }
}


