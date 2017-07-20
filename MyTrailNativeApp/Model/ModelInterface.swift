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


class ModelInterface{
    static var instance = ModelInterface()
    
    var store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    var globalStore: SFSmartStore = SFSmartStore.sharedGlobalStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    
    private init() {
    }
    
    
    //MARK: Get accounts
    func getAllAccounts(){
        Account.registerSoupInTheStore()

        let restAPI = SFRestAPI.sharedInstance()
        let request = restAPI.request(forQuery: Account.getQuery)
        
        restAPI.send(request,
                     fail: { error in
                        print("\(#function): fail, error:\(error)")
        },
                     complete: { response in
                        if let responseDict = response as? [String:Any],
                            let records = responseDict["records"] as? [[String:Any]]{
                            for record in records{
                                self.store.upsertEntries([record],
                                                         toSoup: kAccountSoupName)
                            }
                        }
                        print("\(#function): response:\(response): self.store:\(self.store)")
                        
        })
    }
}


