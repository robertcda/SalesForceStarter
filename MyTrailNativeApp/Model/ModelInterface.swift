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
    lazy var instance = ModelInterface()
    
    var store: SFSmartStore? = nil
    var globalStore: SFSmartStore? = nil
    
    private init() {
        self.store = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
        self.globalStore = SFSmartStore.sharedGlobalStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    }
}
