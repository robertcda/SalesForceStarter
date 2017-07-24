//
//  NameDetailsViewController.swift
//  MyTrailNativeApp
//
//  Created by Robert on 20/07/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore

//MARK: Account->Attribute adapter
struct AccountAttributeAdapter{
    typealias GetStringBlock = ()->String
    typealias SetStringBlock = (String)->Void
    
    let getTitleHandler:GetStringBlock
    let getValueHandler:GetStringBlock
    let setValueHandler:SetStringBlock
    init(getTitleHandler:@escaping GetStringBlock,
         getValueHandler:@escaping GetStringBlock,
         setValueHandler:@escaping SetStringBlock) {
        self.getTitleHandler = getTitleHandler
        self.getValueHandler = getValueHandler
        self.setValueHandler = setValueHandler
    }
    
}
extension AccountAttributeAdapter:AttributeData{
    var title: String{
        get{
            return self.getTitleHandler()
        }
    }
    var value: String{
        get{
            return self.getValueHandler()
        }
        set{
            self.setValueHandler(newValue)
        }
    }
}


//MARK: View Model Definition
struct DetailEntry{
    let attributeData:AccountAttributeAdapter
}

class AccountDetailsViewController: UIViewController {

    var accountNumber:String? = nil
    var accountInformationArray:[(key:String,value:String)] = []
    
    var modelObject: Account? = nil
    var dataSourceModel: [DetailEntry] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeData()
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "AttributeDetailCell", bundle: nil),
                                forCellReuseIdentifier: "AttributeDetailCell")
        
        // Save button enabling & Disabling configuration
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dirtyValueChangedCheck),
                                               name: Account.dirtyChangedNotification.name,
                                               object: nil)
        self.dirtyValueChangedCheck()
        // Do any additional setup after loading the view.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Data initializing
    func initializeData(){
        //Here we use a query that should work on either Force.com or Database.com
    //        let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Name,AccountNumber,OwnerId,Site,AccountSource,AnnualRevenue,BillingAddress FROM Account WHERE AccountNumber = '\(self.accountNumber!)' LIMIT 10");
    //        SFRestAPI.sharedInstance().send(request, delegate: self);

        
        weak var weakSealf = self
        
        // Account Name
        let attributeAdapter = AccountAttributeAdapter(getTitleHandler: { () -> String in
                return "Account Name"
        }, getValueHandler: { () -> String in
            return weakSealf?.modelObject?.name ?? ""
        }) { (stringVal) in
            weakSealf?.modelObject?.name = stringVal
        }
        let accountNameEntry = DetailEntry(attributeData: attributeAdapter)
        self.dataSourceModel.append(accountNameEntry)
        
        // Account Number
        let adapterForAccNumber = AccountAttributeAdapter(getTitleHandler: { () -> String in
            return "Account Number"
        }, getValueHandler: { () -> String in
            return weakSealf?.modelObject?.accountNumber ?? ""
        }) { (stringVal) in
            weakSealf?.modelObject?.accountNumber = stringVal
        }
        let accountNumberEntry = DetailEntry(attributeData: adapterForAccNumber)
        self.dataSourceModel.append(accountNumberEntry)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Save Button
    func dirtyValueChangedCheck(){
        if let model = self.modelObject, model.dirty{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(saveButtonClicked))
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func saveButtonClicked(){
        print("\(#function)")
        self.modelObject?.update(completion: {
            print("Account Update Completed")
        })
    }
}

extension AccountDetailsViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AttributeDetailCell") as? AttributeDetailCell{
            let entry = self.dataSourceModel[indexPath.row]
            cell.attributeData = entry.attributeData
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceModel.count
    }
}

