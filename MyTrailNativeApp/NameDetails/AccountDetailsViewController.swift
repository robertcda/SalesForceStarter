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
        // Do any additional setup after loading the view.
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
        let attributeAdapter = AccountAttributeAdapter(getTitleHandler: { () -> String in
                return "Account Name"
        }, getValueHandler: { () -> String in
            return weakSealf?.modelObject?.name ?? ""
        }) { (stringVal) in
            weakSealf?.modelObject?.name = stringVal
        }
        let accountNameEntry = DetailEntry(attributeData: attributeAdapter)
        self.dataSourceModel.append(accountNameEntry)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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

