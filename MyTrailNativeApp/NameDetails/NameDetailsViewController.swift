//
//  NameDetailsViewController.swift
//  MyTrailNativeApp
//
//  Created by Robert on 20/07/17.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore

class NameDetailsViewController: UIViewController {

    var accountNumber:String? = nil
    var accountInformationArray:[(key:String,value:String)] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeData()
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Data initializing
    func initializeData(){
        //Here we use a query that should work on either Force.com or Database.com
        let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Name,AccountNumber,OwnerId,Site,AccountSource,AnnualRevenue,BillingAddress FROM Account WHERE AccountNumber = '\(self.accountNumber!)' LIMIT 10");
        SFRestAPI.sharedInstance().send(request, delegate: self);
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

extension NameDetailsViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "detail"){
            let entry = self.accountInformationArray[indexPath.row]
            
            cell.textLabel?.text = entry.key
            cell.detailTextLabel?.text = entry.value
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accountInformationArray.count
    }
}

//MARK: - SFDelegate
extension NameDetailsViewController:SFRestDelegate{
    // MARK: - SFRestDelegate
    func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
    {
        let records = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
        if let record = records.first{
            for (key,value) in record{
                self.accountInformationArray.append((key: key as! String, value: "\(value)"))
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        print("\(#function): jsonResponse:\(jsonResponse)")
        
        /*
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"request:didLoadResponse: #records: \(self.dataRows.count)")
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
         */
    }
    
    func request(_ request: SFRestRequest, didFailLoadWithError error: Error)
    {
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"didFailLoadWithError: \(error)")
        // Add your failed error handling here
    }
    
    func requestDidCancelLoad(_ request: SFRestRequest)
    {
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"requestDidCancelLoad: \(request)")
        // Add your failed error handling here
    }
    
    func requestDidTimeout(_ request: SFRestRequest)
    {
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"requestDidTimeout: \(request)")
        // Add your failed error handling here
    }
}
