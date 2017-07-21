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
        //self.store.removeAllSoups()
    }
    
    
    //MARK: Get accounts
    typealias SimpleBlock = ()->Void
    func executeGetAccounts(completion: @escaping SimpleBlock, errorCompletion: SimpleBlock? = nil){
        Account.registerSoupInTheStore()
        
        let restAPI = SFRestAPI.sharedInstance()
        let request = restAPI.request(forQuery: Account.getQuery)
        
        restAPI.send(request,
                     fail: { error in
                        print("\(#function): fail, error:\(error)")
                        errorCompletion?()
        },
                     complete: { response in
                        if let responseDict = response as? [String:Any],
                            let records = responseDict["records"] as? [[String:Any]]{
                            for record in records{
                                do {
                                    try self.store.upsertEntries([record],
                                                             toSoup: kAccountSoupName,
                                                             withExternalIdPath: Account.Attributes.accountNumber.path)
                                }catch let error{
                                    print("\(#function): error:\(error):")
                                }
                                
                            }
                        }
                        print("\(#function): response:\(response): self.store:\(self.store)")
                        completion()
                        
        })
    }
    
    func getAllAccounts(completion:@escaping ([Account]?)->Void){
        self.executeGetAccounts(completion: {
            let query = SFQuerySpec.newAllQuerySpec(kAccountSoupName,
                                                    withOrderPath: Account.Attributes.name.path,
                                                    with: SFSoupQuerySortOrder.ascending,
                                                    withPageSize: 100)
            do {
                let accuntsJsonArray = try self.store.query(with: query, pageIndex: 0)
                let accounts = Account.createAccounts(accountsJSONArray: accuntsJsonArray as! [[String:Any]])
                completion(accounts)
            }catch let e{
                print("\(#function): Error:\(e)")
                completion(nil)
            }
        })
    }
}


